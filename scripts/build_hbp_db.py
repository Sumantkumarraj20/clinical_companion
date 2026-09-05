"""Build an offline PM-JAY HBP SQLite catalog from the official workbook.

Usage:
    python scripts/build_hbp_db.py path/to/pmjay_hbp.xlsx \
        --database assets/pmjay_hbp.sqlite
"""

from __future__ import annotations

import argparse
import re
import sqlite3
from pathlib import Path

import pandas as pd


def _normalize(value: object) -> str:
    text = str(value).replace("\n", " ").strip().lower()
    return re.sub(r"[^a-z0-9]+", " ", text).strip()


def _columns(frame: pd.DataFrame) -> dict[str, str]:
    return {_normalize(column): column for column in frame.columns}


def _find_column(frame: pd.DataFrame, *names: str, required: bool = True) -> str | None:
    columns = _columns(frame)
    for name in names:
        match = columns.get(_normalize(name))
        if match is not None:
            return match
    if required:
        raise ValueError(
            f"Missing one of {names!r}; available columns: {list(frame.columns)!r}"
        )
    return None


def _clean(frame: pd.DataFrame) -> pd.DataFrame:
    result = frame.copy()
    result.columns = [str(column).strip() for column in result.columns]
    return result.dropna(how="all").drop_duplicates()


def _rate(value: object) -> float | None:
    if pd.isna(value):
        return None
    text = re.sub(r"[^0-9.\-]", "", str(value).replace(",", ""))
    try:
        return float(text) if text else None
    except ValueError:
        return None


def _procedure_frame(excel: pd.ExcelFile) -> pd.DataFrame:
    frame = _clean(excel.parse("Procedure sheet"))
    code = _find_column(frame, "Procedure Code", "Package Code", "Code")
    package = _find_column(frame, "Package Name")
    procedure = _find_column(frame, "Procedure Name")
    rate = _find_column(frame, "Tier 2", "Rate", required=False)
    specialty = _find_column(frame, "Specialty", required=False)
    result = pd.DataFrame(
        {
            "procedure_code": frame[code].astype("string").str.strip(),
            "package_name": frame[package].astype("string").str.strip(),
            "procedure_name": frame[procedure].astype("string").str.strip(),
            "rate": frame[rate].map(_rate) if rate else None,
            "specialty": frame[specialty].astype("string").str.strip()
            if specialty
            else "",
        }
    )
    return result.dropna(subset=["procedure_code", "package_name", "procedure_name"])


def _implant_frame(excel: pd.ExcelFile) -> pd.DataFrame:
    links = _clean(excel.parse("Implant Vs Procedure"))
    master = _clean(excel.parse("Implant Master"))
    
    # Corrected column lookups based on the Bihar SHA Excel file structure
    link_proc_code = _find_column(links, "ProcedureCode", "Procedure Code")
    link_implant = _find_column(links, "Implant Code", "Implant Id")
    
    master_implant = _find_column(master, "Implant / High End Consumable Code", "Implant Code")
    name = _find_column(master, "Implant Name", "Name")
    price = _find_column(master, "Implant Price", "Maximum Price", "Max Price", "Rate", required=False)
    
    result = links.rename(columns={link_proc_code: "procedure_code", link_implant: "implant_code"})[
        ["procedure_code", "implant_code"]
    ].merge(
        master.rename(columns={master_implant: "implant_code"}),
        on="implant_code",
        how="inner",
    )
    return pd.DataFrame(
        {
            "procedure_code": result["procedure_code"].astype("string").str.strip(),
            "implant_code": result["implant_code"].astype("string").str.strip(),
            "implant_name": result[name].astype("string").str.strip(),
            "maximum_price": result[price].map(_rate) if price else None,
        }
    ).drop_duplicates()


def _stratification_frame(excel: pd.ExcelFile) -> pd.DataFrame:
    links = _clean(excel.parse("Stratification Vs Procedure"))
    master = _clean(excel.parse("Stratification Master"))
    
    link_code = _find_column(links, "Procedure Code", "Package Code", "Code")
    link_strat = _find_column(links, "Stratification Code", "Stratification Id")
    
    master_strat = _find_column(master, "Stratification Code", "Stratification Id")
    name = _find_column(master, "Stratification Options", "Stratification Details", "Name")
    rule = _find_column(master, "Rule", "Stratification Criteria", required=False)
    
    result = links.rename(
        columns={link_code: "procedure_code", link_strat: "stratification_code"}
    )[["procedure_code", "stratification_code"]].merge(
        master.rename(columns={master_strat: "stratification_code"}),
        on="stratification_code",
        how="inner",
    )
    return pd.DataFrame(
        {
            "procedure_code": result["procedure_code"].astype("string").str.strip(),
            "stratification_code": result["stratification_code"].astype("string").str.strip(),
            "stratification_name": result[name].astype("string").str.strip(),
            "rule": result[rule].astype("string").str.strip() if rule else "",
        }
    ).drop_duplicates()


def _create_schema(connection: sqlite3.Connection) -> None:
    connection.executescript(
        """
        DROP TABLE IF EXISTS hbp_fts;
        DROP TABLE IF EXISTS hbp_implants;
        DROP TABLE IF EXISTS hbp_stratifications;
        DROP TABLE IF EXISTS hbp_procedures;
        
        -- Removed PRIMARY KEY from procedure_code, added auto-incrementing ID
        CREATE TABLE hbp_procedures (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          procedure_code TEXT NOT NULL,
          package_name TEXT NOT NULL,
          procedure_name TEXT NOT NULL,
          rate REAL,
          specialty TEXT NOT NULL DEFAULT ''
        );
        CREATE INDEX hbp_procedures_code_idx ON hbp_procedures(procedure_code);
        
        CREATE TABLE hbp_implants (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          procedure_code TEXT NOT NULL,
          implant_code TEXT NOT NULL,
          implant_name TEXT NOT NULL,
          maximum_price REAL
        );
        CREATE TABLE hbp_stratifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          procedure_code TEXT NOT NULL,
          stratification_code TEXT NOT NULL,
          stratification_name TEXT NOT NULL,
          rule TEXT NOT NULL DEFAULT ''
        );
        CREATE INDEX hbp_implants_procedure_idx ON hbp_implants(procedure_code);
        CREATE INDEX hbp_stratifications_procedure_idx ON hbp_stratifications(procedure_code);
        
        -- Point content_rowid to the new 'id' column
        CREATE VIRTUAL TABLE hbp_fts USING fts5(
          package_name, procedure_name, specialty,
          content='hbp_procedures', content_rowid='id'
        );
        """
    )


def build(source: Path, database: Path) -> None:
    print(f"Reading workbook: {source}")
    with pd.ExcelFile(source) as excel:
        required = {
            "Procedure sheet",
            "Implant Vs Procedure",
            "Implant Master",
            "Stratification Vs Procedure",
            "Stratification Master",
        }
        missing = required.difference(excel.sheet_names)
        if missing:
            raise ValueError(f"Workbook is missing sheets: {sorted(missing)}")
            
        print("Processing procedures...")
        procedures = _procedure_frame(excel)
        print("Processing implants...")
        implants = _implant_frame(excel)
        print("Processing stratifications...")
        stratifications = _stratification_frame(excel)

    database.parent.mkdir(parents=True, exist_ok=True)
    print(f"Writing to database: {database}")
    with sqlite3.connect(database) as connection:
        _create_schema(connection)
        procedures.to_sql("hbp_procedures", connection, if_exists="append", index=False)
        implants.to_sql("hbp_implants", connection, if_exists="append", index=False)
        stratifications.to_sql(
            "hbp_stratifications", connection, if_exists="append", index=False
        )
        connection.execute(
            "INSERT INTO hbp_fts(rowid, package_name, procedure_name, specialty) "
            "SELECT id, package_name, procedure_name, specialty FROM hbp_procedures"
        )
        connection.execute("ANALYZE")
        connection.commit()
        connection.execute("VACUUM")
    print(
        f"Success! Built {len(procedures)} procedures, {len(implants)} implants, "
        f"and {len(stratifications)} stratifications in {database}"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path, help="Path to the PM-JAY .xlsx workbook")
    # Make sure this points to the correct assets folder for your app
    parser.add_argument(
        "--database", type=Path, default=Path("assets/pmjay_hbp.sqlite")
    )
    build(**vars(parser.parse_args()))