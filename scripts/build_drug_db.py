"""Build the offline drug database from the supplied medicine CSV/TSV file."""

from __future__ import annotations

import argparse
import csv
import sqlite3
from pathlib import Path

try:
    import pandas as pd
except ModuleNotFoundError:  # Keep the ETL runnable on minimal Linux installs.
    pd = None


SUBSTITUTES = [f"substitute{i}" for i in range(5)]
SIDE_EFFECTS = [f"sideEffect{i}" for i in range(42)]
USES = [f"use{i}" for i in range(5)]


def _merged(frame: pd.DataFrame, columns: list[str]) -> pd.Series:
    present = [column for column in columns if column in frame.columns]
    if not present:
        return pd.Series("", index=frame.index, dtype="string")
    return (
        frame[present]
        .fillna("")
        .astype(str)
        .apply(
            lambda row: ", ".join(
                value.strip()
                for value in row
                if value.strip() and value.strip().lower() != "nan"
            ),
            axis=1,
        )
    )


def build(source: Path, output: Path) -> None:
    with source.open("r", encoding="utf-8-sig", newline="") as handle:
        sample = handle.read(8192)
    delimiter = csv.Sniffer().sniff(sample, delimiters=",\t").delimiter
    if pd is None:
        _build_without_pandas(source, output, delimiter)
        return
    frame = pd.read_csv(source, sep=delimiter, dtype=str, keep_default_na=False)
    frame.columns = [column.strip() for column in frame.columns]

    data = pd.DataFrame(
        {
            "id": frame.get("id", pd.Series(range(1, len(frame) + 1))),
            "generic_name": frame.get("name", ""),
            "brand_name": frame.get("name", ""),
            "strength": "",
            "dosage_form": "",
            "route": "",
            "category": frame.get("Therapeutic Class", ""),
            "substitutes": _merged(frame, SUBSTITUTES),
            "side_effects": _merged(frame, SIDE_EFFECTS),
            "uses": _merged(frame, USES),
            "chemical_class": frame.get("Chemical Class", ""),
            "price_estimate": "",
            "is_trusted": 0,
            "custom_notes": "",
        }
    )
    data["id"] = data["id"].astype(str)
    output.parent.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(output) as connection:
        connection.executescript(
            """
            DROP TABLE IF EXISTS drug_fts;
            DROP TABLE IF EXISTS drug_master;
            CREATE TABLE drug_master (
              id TEXT PRIMARY KEY,
              owner_id TEXT NOT NULL DEFAULT 'drug-catalog',
              generic_name TEXT NOT NULL,
              brand_name TEXT,
              strength TEXT,
              dosage_form TEXT,
              route TEXT,
              category TEXT,
              is_active INTEGER NOT NULL DEFAULT 1,
              metadata TEXT NOT NULL DEFAULT '{}',
              created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
              updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
              last_synced_at TEXT,
              substitutes TEXT NOT NULL DEFAULT '',
              side_effects TEXT NOT NULL DEFAULT '',
              uses TEXT NOT NULL DEFAULT '',
              chemical_class TEXT NOT NULL DEFAULT '',
              price_estimate TEXT,
              is_trusted INTEGER NOT NULL DEFAULT 0,
              custom_notes TEXT
            );
            """
        )
        data.to_sql("drug_master", connection, if_exists="append", index=False)
        connection.executescript(
            """
            CREATE VIRTUAL TABLE drug_fts USING fts5(
              brand_name, substitutes, uses,
              content='drug_master', content_rowid='rowid',
              tokenize='unicode61'
            );
            INSERT INTO drug_fts(rowid, brand_name, substitutes, uses)
              SELECT rowid, brand_name, substitutes, uses FROM drug_master;
            CREATE TRIGGER drug_master_ai AFTER INSERT ON drug_master BEGIN
              INSERT INTO drug_fts(rowid, brand_name, substitutes, uses)
              VALUES (new.rowid, new.brand_name, new.substitutes, new.uses);
            END;
            CREATE TRIGGER drug_master_au AFTER UPDATE ON drug_master BEGIN
              INSERT INTO drug_fts(drug_fts, rowid, brand_name, substitutes, uses)
              VALUES ('delete', old.rowid, old.brand_name, old.substitutes, old.uses);
              INSERT INTO drug_fts(rowid, brand_name, substitutes, uses)
              VALUES (new.rowid, new.brand_name, new.substitutes, new.uses);
            END;
            CREATE TRIGGER drug_master_ad AFTER DELETE ON drug_master BEGIN
              INSERT INTO drug_fts(drug_fts, rowid, brand_name, substitutes, uses)
              VALUES ('delete', old.rowid, old.brand_name, old.substitutes, old.uses);
            END;
            """
        )
        connection.execute(
            "CREATE INDEX IF NOT EXISTS drug_master_trusted_idx "
            "ON drug_master(is_trusted)"
        )


def _build_without_pandas(source: Path, output: Path, delimiter: str) -> None:
    """Small stdlib fallback for generating the same schema without pandas."""
    with source.open("r", encoding="utf-8-sig", newline="") as handle:
        rows = csv.DictReader(handle, delimiter=delimiter)
        records = list(rows)
    output.parent.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(output) as connection:
        connection.executescript(
            "DROP TABLE IF EXISTS drug_fts; DROP TABLE IF EXISTS drug_master;"
            "CREATE TABLE drug_master (id TEXT PRIMARY KEY, owner_id TEXT NOT NULL DEFAULT 'drug-catalog',"
            "generic_name TEXT NOT NULL, brand_name TEXT, strength TEXT, dosage_form TEXT, route TEXT,"
            "category TEXT, is_active INTEGER NOT NULL DEFAULT 1, metadata TEXT NOT NULL DEFAULT '{}',"
            "created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,"
            "last_synced_at TEXT, substitutes TEXT NOT NULL DEFAULT '', side_effects TEXT NOT NULL DEFAULT '',"
            "uses TEXT NOT NULL DEFAULT '', chemical_class TEXT NOT NULL DEFAULT '', price_estimate TEXT,"
            "is_trusted INTEGER NOT NULL DEFAULT 0, custom_notes TEXT);"
        )
        for index, row in enumerate(records, 1):
            values = lambda names: ", ".join(
                row.get(name, "").strip() for name in names if row.get(name, "").strip()
            )
            connection.execute(
                "INSERT INTO drug_master (id,generic_name,brand_name,category,substitutes,"
                "side_effects,uses,chemical_class) VALUES (?,?,?,?,?,?,?,?)",
                (
                    row.get("id") or str(index),
                    row.get("name", ""),
                    row.get("name", ""),
                    row.get("Therapeutic Class", ""),
                    values(SUBSTITUTES),
                    values(SIDE_EFFECTS),
                    values(USES),
                    row.get("Chemical Class", ""),
                ),
            )
        connection.executescript(
            "CREATE VIRTUAL TABLE drug_fts USING fts5(brand_name,substitutes,uses,"
            "content='drug_master',content_rowid='rowid');"
            "INSERT INTO drug_fts(rowid,brand_name,substitutes,uses)"
            "SELECT rowid,brand_name,substitutes,uses FROM drug_master;"
            "CREATE TRIGGER drug_master_ai AFTER INSERT ON drug_master BEGIN"
            " INSERT INTO drug_fts(rowid,brand_name,substitutes,uses)"
            " VALUES(new.rowid,new.brand_name,new.substitutes,new.uses); END;"
            "CREATE TRIGGER drug_master_au AFTER UPDATE ON drug_master BEGIN"
            " INSERT INTO drug_fts(drug_fts,rowid,brand_name,substitutes,uses)"
            " VALUES('delete',old.rowid,old.brand_name,old.substitutes,old.uses);"
            " INSERT INTO drug_fts(rowid,brand_name,substitutes,uses)"
            " VALUES(new.rowid,new.brand_name,new.substitutes,new.uses); END;"
            "CREATE TRIGGER drug_master_ad AFTER DELETE ON drug_master BEGIN"
            " INSERT INTO drug_fts(drug_fts,rowid,brand_name,substitutes,uses)"
            " VALUES('delete',old.rowid,old.brand_name,old.substitutes,old.uses); END;"
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument(
        "--output", type=Path, default=Path("assets/clinical_drugs.sqlite")
    )
    args = parser.parse_args()
    build(args.source, args.output)
