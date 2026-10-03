import urllib.request
import urllib.error
import json
import sqlite3
import time
from pathlib import Path

GOOGLE_MACRO_URL = "https://script.googleusercontent.com/macros/echo?user_content_key=AUkAhnQPv-ZEsJ0CRg4S7eYql_21FmDnVaEQx3DKD9iyKAZ9yef2Z5nAUsXv5auJdoFJb89DeBWvVlehVktOxX965rKnnI-mVI4ky00A53dIxK9zevwzKXQI8iPxc9xysXL9dHSrtzHY_PjK3-Kt3PFzlGZEsHAjd6TWKIgE44OxfrZwwGa5MLhPz1NdxZAExFMIW3jCVPGNIeMgNGt6bjPD2BkwYoiFfvw2NMWlt_2Hw5hScPO8WgesjzW4UjwgcImm8wDeCIAgte8JdPlYl3sDRPlgFUAIAg&lib=MTXeStcT_4zsqnkjKuBXjUR07KVSSVcGI"
DB_PATH = Path("assets/clinical_drugs.sqlite")

def fetch_sheet_data_with_retry(max_retries=3, delay=3):
    print("🌐 Fetching latest clinical data from Google Sheets...")
    req = urllib.request.Request(GOOGLE_MACRO_URL, headers={'User-Agent': 'Mozilla/5.0'})
    
    for attempt in range(1, max_retries + 1):
        try:
            with urllib.request.urlopen(req, timeout=30) as response:
                return json.loads(response.read().decode('utf-8'))
        except (urllib.error.HTTPError, urllib.error.URLError, TimeoutError) as e:
            print(f"⚠️ Attempt {attempt} failed ({e}). Retrying in {delay} seconds...")
            if attempt == max_retries:
                raise e
            time.sleep(delay)
            delay *= 2  # Exponential backoff

def build_sqlite(data_dict):
    print(f"🏗️ Building SQLite database at {DB_PATH}...")
    
    DB_PATH.parent.mkdir(exist_ok=True)
    
    if DB_PATH.exists():
        DB_PATH.unlink()
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    try:
        for table_name, rows in data_dict.items():
            if not rows:
                continue
                
            print(f"   ➔ Processing table: {table_name} ({len(rows)} rows)")
            
            columns = list(rows[0].keys())
            
            col_defs = ", ".join([f'"{col}" TEXT' for col in columns])
            cursor.execute(f'DROP TABLE IF EXISTS "{table_name}"')
            cursor.execute(f'CREATE TABLE "{table_name}" ({col_defs})')
            
            placeholders = ", ".join(["?"] * len(columns))
            insert_query = f'INSERT INTO "{table_name}" VALUES ({placeholders})'
            
            for row in rows:
                values = [str(row.get(col, "")) for col in columns]
                cursor.execute(insert_query, values)
                
        conn.commit()
        conn.execute("PRAGMA user_version = 1")
        print("✅ Database built successfully.")
        
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        conn.close()

if __name__ == "__main__":
    print("==================================================")
    print("   🏥 Nightly DrugMaster Database Compiler")
    print("==================================================")
    try:
        sheet_data = fetch_sheet_data_with_retry()
        build_sqlite(sheet_data)
        print("✅ Success: clinical_drugs.sqlite compiled securely.")
    except Exception as e:
        print(f"❌ Critical Error: {e}")
        exit(1)