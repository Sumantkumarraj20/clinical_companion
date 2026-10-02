"""Validation, data quality scoring, reporting, and review queue generation."""

from __future__ import annotations
import json
import os
from typing import Any
from .models import DrugRecord, ReviewQueueItem
from .knowledge import KnowledgeBase


class DataValidator:
    """Validates compiled records, produces metrics, and exports review queue."""

    def __init__(self, kb: KnowledgeBase):
        self.kb = kb

    def validate_record(self, record: DrugRecord) -> list[str]:
        """Verify data consistency and check for anomalies.

        Covers: canonical/ingredient consistency, duplicate canonical
        molecules (checked at report level), unknown ingredients, unknown
        dosage forms, potential combination parsing failures, and missing
        clinical knowledge on resolved records.
        """
        issues = []
        if not record.canonical_name and record.data_status != "UNRESOLVED":
            issues.append("MISSING_CANONICAL_NAME_FOR_RESOLVED_RECORD")
        if record.canonical_name and not record.ingredients:
            issues.append("CANONICAL_RECORD_HAS_NO_INGREDIENTS")
        if record.data_status in ("RESOLVED", "PARTIALLY_RESOLVED"):
            for ing in record.ingredients:
                if not self.kb.is_canonical(ing):
                    issues.append(f"UNKNOWN_INGREDIENT:{ing}")
            if " + " in (record.canonical_name or "") and len(record.ingredients) < 2:
                issues.append("POTENTIAL_COMBINATION_PARSING_FAILURE")
            for df in record.dosage_forms:
                known_forms = set(self.kb.dosage_forms.keys()) | {
                    v for variants in self.kb.dosage_forms.values() for v in variants
                }
                if df.lower() not in {k.lower() for k in known_forms}:
                    issues.append(f"UNKNOWN_DOSAGE_FORM:{df}")
                    break
            if not record.indications:
                issues.append("MISSING_CLINICAL_KNOWLEDGE:indications")
            if not record.side_effects:
                issues.append("MISSING_CLINICAL_KNOWLEDGE:side_effects")
            if not record.drug_classes:
                issues.append("MISSING_CLINICAL_KNOWLEDGE:classes")
        return issues

    def build_report(
        self,
        total_source_rows: int,
        unique_normalized_names: int,
        compiled_records: list[DrugRecord],
        unresolved_queue: list[ReviewQueueItem]
    ) -> dict[str, Any]:
        """Generate comprehensive compilation metrics dictionary."""
        resolved = sum(1 for r in compiled_records if r.data_status == "RESOLVED")
        partially_resolved = sum(1 for r in compiled_records if r.data_status == "PARTIALLY_RESOLVED")
        unresolved = sum(1 for r in compiled_records if r.data_status == "UNRESOLVED")

        # Clinical coverage among resolved records
        resolved_records = [r for r in compiled_records if r.data_status in ("RESOLVED", "PARTIALLY_RESOLVED")]
        total_res = len(resolved_records) or 1

        indication_cov = sum(1 for r in resolved_records if r.indications) / total_res
        side_effect_cov = sum(1 for r in resolved_records if r.side_effects) / total_res
        class_cov = sum(1 for r in resolved_records if r.drug_classes) / total_res
        pearls_cov = sum(1 for r in resolved_records if r.prescribing_pearls) / total_res

        total_flags = sum(len(r.clinical_flags) for r in compiled_records)

        # Average quality score
        avg_score = sum(r.data_quality_score for r in compiled_records) / (len(compiled_records) or 1)

        # Resolution mechanism breakdown (best-effort, deterministic):
        # relies on resolver data_source/ingredients rather than row counts.
        manual_overrides = sum(1 for r in compiled_records if r.data_source == "MANUAL_OVERRIDE")

        # Validation diagnostics across compiled records
        validation_issues: dict[str, int] = {}
        for r in compiled_records:
            for issue in self.validate_record(r):
                validation_issues[issue] = validation_issues.get(issue, 0) + 1

        # Duplicate canonical molecules should be zero post-dedup; report defensively
        seen: set[str] = set()
        duplicate_canonical_molecules = 0
        for r in compiled_records:
            if r.canonical_name:
                key = r.canonical_name.lower().strip()
                if key in seen:
                    duplicate_canonical_molecules += 1
                else:
                    seen.add(key)

        report = {
            "source_rows": total_source_rows,
            "unique_normalized_names": unique_normalized_names,
            "canonical_molecules": len(compiled_records),
            "resolved": resolved,
            "partially_resolved": partially_resolved,
            "unresolved": unresolved,
            "manual_overrides": manual_overrides,
            "duplicate_canonical_molecules": duplicate_canonical_molecules,
            "validation_issues": validation_issues,
            "knowledge_coverage": {
                "indications": round(indication_cov, 4),
                "side_effects": round(side_effect_cov, 4),
                "classes": round(class_cov, 4),
                "prescribing_pearls": round(pearls_cov, 4)
            },
            "average_quality_score": round(avg_score, 2),
            "total_clinical_flags_assigned": total_flags,
            "review_queue_size": len(unresolved_queue),
            "knowledge_version": self.kb.version
        }
        return report

    def export_review_queue(self, queue: list[ReviewQueueItem], output_path: str) -> None:
        """Export unresolved or ambiguous items to JSONL for human curation."""
        os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
        with open(output_path, "w", encoding="utf-8") as f:
            for item in queue:
                line_data = {
                    "source_name": item.source_name,
                    "normalized_name": item.normalized_name,
                    "candidate_matches": item.candidate_matches,
                    "reason": item.reason,
                    "status": item.status,
                    "frequency": item.frequency
                }
                f.write(json.dumps(line_data, ensure_ascii=False) + "\n")

    def export_build_report(self, report: dict[str, Any], output_path: str) -> None:
        """Write the build report JSON."""
        os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
