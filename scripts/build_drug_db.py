import urllib.request
import json
import sqlite3
from pathlib import Path

# Paste your Web App URL from Step 1 here
GOOGLE_MACRO_URL = "https://script.googleusercontent.com/macros/echo?user_content_key=AUkAhnTy8LXWIEWA7t3j_8nGNBGCAOPRx_PQNy9fw9i2oDGDbX36lWNy0cI1bB2WznJ-DFiBDsZFJTH4FOvjKvlwnNglZd83N_RbLVUarR21TAkGaUS8Hz1Vl2epJiNmmWD93NwHSo7PC-umX-3VbZnvKsvuPVp7wFRPFLkHsJzhkfR5wgAFoFWMgT_4iPmLs7EJimEvElOwG7r9gpvVgWunXN-7DXX9xHK7Kd2DJY3J7iZhU_-22y9XwlxHq_WHmudrdFWrJ0TeT1MwYgjhLwzWc5gkdGNkyg&lib=MTXeStcT_4zsqnkjKuBXjUR07KVSSVcGI"
DB_PATH = Path("assets/clinical_drugs.sqlite")

def fetch_sheet_data():
    print("🌐 Fetching latest clinical data from Google Sheets...")
    req = urllib.request.Request(GOOGLE_MACRO_URL)
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode('utf-8'))

def build_sqlite(data_dict):
    print(f"🏗️ Building SQLite database at {DB_PATH}...")
    
    # Ensure assets folder exists
    DB_PATH.parent.mkdir(exist_ok=True)
    
    # Connect to SQLite (this creates a fresh DB or overwrites tables)
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        
        for table_name, rows in data_dict.items():
            if not rows:
                continue
                
            print(f"   ➔ Processing table: {table_name} ({len(rows)} rows)")
            
            # Extract column names from the first row's keys
            columns = list(rows[0].keys())
            
            # Create a clean table dynamically based on Sheet headers
            col_defs = ", ".join([f'"{col}" TEXT' for col in columns])
            cursor.execute(f'DROP TABLE IF EXISTS "{table_name}"')
            cursor.execute(f'CREATE TABLE "{table_name}" ({col_defs})')
            
            # Insert the data
            placeholders = ", ".join(["?"] * len(columns))
            insert_query = f'INSERT INTO "{table_name}" VALUES ({placeholders})'
            
            for row in rows:
                values = [str(row.get(col, "")) for col in columns]
                cursor.execute(insert_query, values)
                
        # Set Drift compatability baseline
        conn.execute("PRAGMA user_version = 1")
        conn.execute("VACUUM")

if __name__ == "__main__":
    print("==================================================")
    print("   🏥 Nightly DrugMaster Database Compiler")
    print("==================================================")
    try:
        sheet_data = fetch_sheet_data()
        build_sqlite(sheet_data)
        print("✅ Success: clinical_drugs.sqlite updated securely.")
    except Exception as e:
        print(f"❌ Critical Error: {e}")
        exit(1)