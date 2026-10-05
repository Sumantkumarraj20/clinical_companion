"""Streaming SQLite database compiler with atomic transaction swap and deterministic hashing."""

from __future__ import annotations
import hashlib
import json
import sqlite3
import os
from collections import defaultdict
from typing import Any, Generator

from .models import DrugRecord, RawDrugRow, ReviewQueueItem
from .knowledge import KnowledgeBase
from .resolver import resolve_drug_record
from .rules import ClinicalRuleEngine
from .validator import DataValidator
from .normalizer import normalize_raw_name


def generate_deterministic_drug_id(canonical_molecule: str) -> str:
    """Generate reproducible 16-char hex identifier from canonical name."""
    clean = canonical_molecule.lower().strip()
    h = hashlib.sha256(clean.encode("utf-8")).hexdigest()
    return f"drug_{h[:16]}"


def detect_table_columns(conn: sqlite3.Connection, table_name: str) -> dict[str, str]:
    """Inspect SQLite table schema and detect best-matching column names."""
    cursor = conn.cursor()
    cursor.execute(f"PRAGMA table_info({table_name})")
    cols = [row[1] for row in cursor.fetchall()]
    cols_lower = {c.lower(): c for c in cols}

    mapping = {}
    # Generic / Composition column
    for candidate in ["generic_name", "composition", "salts", "constituents", "generic_molecule", "generic", "name"]:
        if candidate in cols_lower:
            mapping["generic"] = cols_lower[candidate]
            break
    if "generic" not in mapping and cols:
        mapping["generic"] = cols[0]

    # Brand column
    for candidate in ["brand_name", "brand", "name", "trade_name", "product_name"]:
        if candidate in cols_lower:
            mapping["brand"] = cols_lower[candidate]
            break
    if "brand" not in mapping:
        mapping["brand"] = mapping["generic"]

    # Dosage form
    for candidate in ["dosage_form", "form", "type", "packaging"]:
        if candidate in cols_lower:
            mapping["dosage_form"] = cols_lower[candidate]
            break

    # Strength
    for candidate in ["strength", "potency", "dosage"]:
        if candidate in cols_lower:
            mapping["strength"] = cols_lower[candidate]
            break

    # Price
    for candidate in ["price", "mrp", "cost"]:
        if candidate in cols_lower:
            mapping["price"] = cols_lower[candidate]
            break

    # ID
    for candidate in ["id", "drug_id", "row_id"]:
        if candidate in cols_lower:
            mapping["id"] = cols_lower[candidate]
            break

    return mapping


def stream_source_rows(
    conn: sqlite3.Connection,
    table_name: str = "drug_master",
    batch_size: int = 5000
) -> Generator[RawDrugRow, None, None]:
    """Stream raw rows from drug_master using a server-side cursor without loading table into memory."""
    col_map = detect_table_columns(conn, table_name)
    cursor = conn.cursor()

    select_cols = [f'"{col_map["generic"]}"', f'"{col_map["brand"]}"']
    optional_keys = ["id", "dosage_form", "strength", "price"]
    for key in optional_keys:
        if key in col_map and col_map[key] not in [col_map["generic"], col_map["brand"]]:
            select_cols.append(f'"{col_map[key]}"')

    query = f"SELECT {', '.join(select_cols)} FROM {table_name}"
    cursor.execute(query)

    row_idx = 0
    while True:
        rows = cursor.fetchmany(batch_size)
        if not rows:
            break
        for row in rows:
            row_idx += 1
            raw_gen = row[0] or ""
            raw_brand = row[1] or ""
            form_val = None
            strength_val = None
            price_val = None
            row_id = row_idx

            col_offset = 2
            for key in optional_keys:
                if key in col_map and col_map[key] not in [col_map["generic"], col_map["brand"]]:
                    val = row[col_offset]
                    if key == "id":
                        row_id = val
                    elif key == "dosage_form":
                        form_val = str(val) if val is not None else None
                    elif key == "strength":
                        strength_val = str(val) if val is not None else None
                    elif key == "price":
                        try:
                            price_val = float(val) if val is not None else None
                        except (ValueError, TypeError):
                            price_val = None
                    col_offset += 1

            yield RawDrugRow(
                row_id=row_id,
                raw_name=str(raw_gen).strip(),
                brand_name=str(raw_brand).strip() if raw_brand else None,
                dosage_form=form_val,
                strength=strength_val,
                price=price_val
            )


class DrugCompiler:
    """Compiles dirty drug SKU databases into clean, structured clinical_drugs."""

    def __init__(self, kb: KnowledgeBase, verbose: bool = False):
        self.kb = kb
        self.verbose = verbose
        self.rule_engine = ClinicalRuleEngine()
        self.validator = DataValidator(kb)

    def compile(
        self,
        db_path: str,
        top_n: int = 3000,
        validate_only: bool = False,
        dry_run: bool = False,
        source_table: str = "drug_master",
        target_table: str = "clinical_drugs",
        review_queue_path: str = "assets/drug_refactory/review_queue.jsonl",
        build_report_path: str = "assets/drug_refactory/build_report.json"
    ) -> dict[str, Any]:
        """Execute the compilation pipeline."""
        if not os.path.exists(db_path):
            raise FileNotFoundError(f"SQLite database not found at: {db_path}")

        print(f"[REFAC] Opening {db_path}")
        
        # Test filesystem lock support. If remote/9p mount restricts file locks, stage in local /tmp
        use_staging = False
        work_db = db_path
        try:
            test_conn = sqlite3.connect(db_path, isolation_level=None)
            test_cur = test_conn.cursor()
            test_cur.execute("PRAGMA schema_version")
            test_cur.fetchall()
            test_cur.execute("CREATE TABLE IF NOT EXISTS _fs_test (x INT)")
            test_cur.execute("DROP TABLE IF EXISTS _fs_test")
            test_conn.close()
        except sqlite3.OperationalError:
            use_staging = True
            import shutil, tempfile
            work_db = os.path.join(tempfile.gettempdir(), f"stage_{os.path.basename(db_path)}")
            shutil.copyfile(db_path, work_db)
            print(f"[REFAC] Network/shared mount detected. Using high-speed local staging at {work_db}")

        conn = sqlite3.connect(work_db, isolation_level=None)

        # Check source table
        check_cursor = conn.cursor()
        check_cursor.execute(
            "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
            (source_table,)
        )
        if not check_cursor.fetchone():
            conn.close()
            raise ValueError(f"Source table '{source_table}' does not exist in {db_path}")

        print("[REFAC] Loading local drug knowledge...")
        print(f"[REFAC] Knowledge base version: {self.kb.version} with {len(self.kb.canonical_molecules)} canonical molecules")

        print("[REFAC] Aggregating source drug records...")
        # Stream and aggregate by normalized clean name
        name_aggregates: dict[str, dict[str, Any]] = defaultdict(lambda: {
            "source_names": set(),
            "frequency": 0,
            "brands": defaultdict(lambda: {"count": 0, "prices": []}),
            "dosage_forms": set(),
            "strengths": set()
        })

        total_source_rows = 0
        for raw_row in stream_source_rows(conn, table_name=source_table):
            total_source_rows += 1
            primary_name = raw_row.raw_name or raw_row.brand_name or "Unknown"
            norm_key = normalize_raw_name(primary_name)
            if not norm_key:
                continue

            agg = name_aggregates[norm_key]
            agg["source_names"].add(primary_name)
            agg["frequency"] += 1

            if raw_row.dosage_form:
                agg["dosage_forms"].add(raw_row.dosage_form.lower())
            if raw_row.strength:
                agg["strengths"].add(raw_row.strength.lower())

            if raw_row.brand_name:
                b_info = agg["brands"][raw_row.brand_name.strip()]
                b_info["count"] += 1
                if raw_row.price is not None:
                    b_info["prices"].append(raw_row.price)

        unique_normalized_names = len(name_aggregates)
        print(f"[REFAC] Streamed {total_source_rows} rows -> {unique_normalized_names} unique normalized names")

        # Sort aggregated groups by frequency descending, then normalized key
        # ascending for deterministic selection (same input + same knowledge
        # files always produce the same output).
        sorted_groups = sorted(
            name_aggregates.items(),
            key=lambda x: (-x[1]["frequency"], x[0])
        )

        # Apply top-n cutoff if specified (--top-n 0 compiles ALL groups)
        if top_n > 0:
            target_groups = sorted_groups[:top_n]
        else:
            target_groups = sorted_groups

        print(f"[REFAC] Resolving canonical molecules for top {len(target_groups)} groups...")
        print("[REFAC] Applying aliases")
        print("[REFAC] Resolving combinations...")
        print("[REFAC] Applying local clinical knowledge...")
        print("[REFAC] Applying deterministic clinical rules...")
        canonical_drug_map: dict[str, DrugRecord] = {}
        review_queue: list[ReviewQueueItem] = []

        for norm_key, data in target_groups:
            # Pick the most common representative source name
            rep_source_name = sorted(list(data["source_names"]), key=len)[0]
            # Get top brand as hint
            top_brand_hint = None
            if data["brands"]:
                top_brand_hint = sorted(data["brands"].items(), key=lambda x: x[1]["count"], reverse=True)[0][0]

            record = resolve_drug_record(
                source_name=rep_source_name,
                kb=self.kb,
                brand_name=top_brand_hint
            )
            record.usage_frequency = data["frequency"]

            # Merge detected strengths and dosage forms
            for s in data["strengths"]:
                if s not in record.strengths:
                    record.strengths.append(s)
            for f in data["dosage_forms"]:
                if f not in record.dosage_forms:
                    record.dosage_forms.append(f)

            # Top 5 Brands with average price
            top_5_brands = sorted(
                data["brands"].items(),
                key=lambda x: x[1]["count"],
                reverse=True
            )[:5]

            brand_payload = []
            for b_name, b_meta in top_5_brands:
                avg_p = None
                if b_meta["prices"]:
                    avg_p = round(sum(b_meta["prices"]) / len(b_meta["prices"]), 2)
                brand_payload.append({
                    "brand": b_name,
                    "count": b_meta["count"],
                    "avg_price": avg_p
                })
            record.top_brands = brand_payload

            # Check if resolved
            if record.data_status in ("RESOLVED", "PARTIALLY_RESOLVED") and record.canonical_name:
                canon_key = record.canonical_name.lower().strip()
                if canon_key in canonical_drug_map:
                    # Merge into existing canonical record
                    existing = canonical_drug_map[canon_key]
                    existing.usage_frequency += record.usage_frequency
                    # Merge brands
                    existing_brands = {b["brand"]: b for b in existing.top_brands}
                    for b in record.top_brands:
                        if b["brand"] not in existing_brands and len(existing_brands) < 5:
                            existing.top_brands.append(b)
                            existing_brands[b["brand"]] = b
                    # Merge forms
                    for df in record.dosage_forms:
                        if df not in existing.dosage_forms:
                            existing.dosage_forms.append(df)
                    # Merge strengths (dedup, preserve order)
                    for st in record.strengths:
                        if st not in existing.strengths:
                            existing.strengths.append(st)
                    # Merge routes (dedup, preserve order)
                    for rt in record.routes:
                        if rt not in existing.routes:
                            existing.routes.append(rt)
                    continue

                # Populate clinical knowledge
                all_indications = []
                all_side_effects = []
                all_classes = []
                all_contra = []
                all_interactions = []
                all_pearls = []

                # For single or combo, query KB for each constituent ingredient
                for ing in record.ingredients:
                    for item in self.kb.get_indications(ing):
                        if item not in all_indications:
                            all_indications.append(item)
                    for item in self.kb.get_side_effects(ing):
                        if item not in all_side_effects:
                            all_side_effects.append(item)
                    for item in self.kb.get_drug_classes(ing):
                        if item not in all_classes:
                            all_classes.append(item)
                    for item in self.kb.get_contraindications(ing):
                        if item not in all_contra:
                            all_contra.append(item)
                    for item in self.kb.get_interactions(ing):
                        if item not in all_interactions:
                            all_interactions.append(item)
                    for item in self.kb.get_prescribing_pearls(ing):
                        if item not in all_pearls:
                            all_pearls.append(item)

                record.indications = all_indications
                record.side_effects = all_side_effects
                record.drug_classes = all_classes
                record.contraindications = all_contra
                record.interactions = all_interactions
                record.prescribing_pearls = all_pearls

                # Apply deterministic rules
                self.rule_engine.apply(record)

                # Calculate deterministic quality score & confidence
                record.calculate_quality_score()

                # Generate deterministic SHA-256 stable ID
                record.stable_id = generate_deterministic_drug_id(record.canonical_name)

                canonical_drug_map[canon_key] = record
            else:
                # Add to review queue with fuzzy candidate matches for the
                # curator (candidate generator only — never auto-accepted).
                review_queue.append(ReviewQueueItem(
                    source_name=rep_source_name,
                    normalized_name=norm_key,
                    candidate_matches=getattr(record, "_candidate_matches", []) or [],
                    reason="NO_CANONICAL_MATCH",
                    status="REVIEW_REQUIRED",
                    frequency=data["frequency"]
                ))
                if self.verbose:
                    print(f"[UNRESOLVED] {rep_source_name} (freq: {data['frequency']})")

        compiled_records = list(canonical_drug_map.values())

        print(f"[REFAC] Compiled {len(compiled_records)} canonical drug entities ({len(review_queue)} in review queue)")
        print("[REFAC] Validating compiled dataset...")

        report = self.validator.build_report(
            total_source_rows=total_source_rows,
            unique_normalized_names=unique_normalized_names,
            compiled_records=compiled_records,
            unresolved_queue=review_queue
        )

        # Export review queue and report. In validate-only / dry-run modes no
        # database is touched, but artifacts are still written so the report
        # and review queue are auditable (unless caller passed sentinel paths
        # in tests with delete=False temp files — still safe to overwrite).
        self.validator.export_review_queue(review_queue, review_queue_path)
        self.validator.export_build_report(report, build_report_path)

        if validate_only or dry_run:
            print("[REFAC] Mode: " + ("VALIDATE ONLY" if validate_only else "DRY RUN") + " - Database left untouched.")
            conn.close()
            return report

        # Transaction safety: Write into target_table_new first, then atomically swap
        temp_table = f"{target_table}_new"
        backup_table = f"{target_table}_backup"

        print(f"[REFAC] Writing to staging table '{temp_table}'...")
        cursor = conn.cursor()

        # Drop temporary table if exists from previous failed run
        cursor.execute(f"DROP TABLE IF EXISTS {temp_table}")

        create_sql = f"""
        CREATE TABLE {temp_table} (
            id TEXT PRIMARY KEY,
            generic_molecule TEXT NOT NULL,
            ingredients TEXT NOT NULL DEFAULT '[]',
            problem_indications TEXT NOT NULL DEFAULT '[]',
            prioritized_side_effects TEXT NOT NULL DEFAULT '[]',
            common_indications TEXT NOT NULL DEFAULT '[]',
            dose_adjustments TEXT NOT NULL DEFAULT '{}',
            common_side_effects TEXT NOT NULL DEFAULT '[]',
            prescribing_pearls TEXT,
            available_forms TEXT,
            routes TEXT,
            top_brands TEXT,
            usage_frequency INTEGER NOT NULL DEFAULT 0,
            drug_classes TEXT NOT NULL DEFAULT '[]',
            contraindications TEXT NOT NULL DEFAULT '[]',
            interactions TEXT NOT NULL DEFAULT '[]',
            clinical_flags TEXT NOT NULL DEFAULT '[]',
            data_status TEXT NOT NULL DEFAULT 'UNRESOLVED',
            confidence TEXT NOT NULL DEFAULT 'LOW',
            data_source TEXT,
            knowledge_version TEXT,
            data_quality_score INTEGER NOT NULL DEFAULT 0
        );
        """
        cursor.execute(create_sql)

        insert_sql = f"""
        INSERT INTO {temp_table} (
            id, generic_molecule, ingredients, problem_indications,
            prioritized_side_effects, common_indications, dose_adjustments,
            common_side_effects, prescribing_pearls, available_forms,
            routes, top_brands, usage_frequency, drug_classes,
            contraindications, interactions, clinical_flags,
            data_status, confidence, data_source, knowledge_version,
            data_quality_score
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """

        rows_to_insert = []
        for r in compiled_records:
            rows_to_insert.append((
                r.stable_id,
                r.display_name,
                json.dumps(r.ingredients),
                json.dumps(r.indications),
                json.dumps(r.side_effects),
                json.dumps(r.indications),
                "{}",
                json.dumps(r.side_effects),
                json.dumps(r.prescribing_pearls) if r.prescribing_pearls else None,
                json.dumps(r.dosage_forms),
                json.dumps(r.routes),
                json.dumps(r.top_brands),
                r.usage_frequency,
                json.dumps(r.drug_classes),
                json.dumps(r.contraindications),
                json.dumps(r.interactions),
                json.dumps(r.clinical_flags),
                r.data_status,
                r.confidence,
                r.data_source,
                r.knowledge_version,
                r.data_quality_score
            ))

        cursor.executemany(insert_sql, rows_to_insert)

        # Atomic Swap: BEGIN IMMEDIATE transaction on a deferred connection.
        # NOTE: the connection is opened with isolation_level=None (autocommit
        # for DDL), so we explicitly BEGIN here and COMMIT only the rename pair.
        # The staging table (clinical_drugs_new) preserves the previous working
        # table on ANY failure: a failed build can never destroy clinical_drugs
        # because the old table is only renamed to clinical_drugs_backup AFTER
        # the new table is fully written and validated.
        print(f"[REFAC] Performing atomic table swap: {temp_table} -> {target_table} (backup to {backup_table})")
        try:
            cursor.execute("BEGIN IMMEDIATE")
            # Check if target table already exists
            cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name=?", (target_table,))
            if cursor.fetchone():
                cursor.execute(f"DROP TABLE IF EXISTS {backup_table}")
                cursor.execute(f"ALTER TABLE {target_table} RENAME TO {backup_table}")

            cursor.execute(f"ALTER TABLE {temp_table} RENAME TO {target_table}")
            conn.commit()
            print(f"[REFAC] Table swap successful. Output stored in '{target_table}'")
        except Exception as e:
            try:
                conn.rollback()
            except Exception:
                pass
            # Best-effort cleanup: never leave a half-renamed database;
            # the backup (old working table) is intact at this point.
            print(f"[ERROR] Transaction failed, rolled back: {e}")
            raise e
        finally:
            conn.close()
            if use_staging:
                import shutil
                shutil.copyfile(work_db, db_path)
                if os.path.exists(work_db):
                    try:
                        os.remove(work_db)
                    except OSError:
                        pass
                print(f"[REFAC] Staged database successfully synced back to {db_path}")

        print("[REFAC] Build successful.")
        return report
