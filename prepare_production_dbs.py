import sqlite3
from pathlib import Path
from http.server import HTTPServer, BaseHTTPRequestHandler
import urllib.parse

# Path to your databases
DATABASES = {
    "Clinical Drugs": Path("assets/clinical_drugs.sqlite"),
    "PM-JAY HBP": Path("assets/pmjay_hbp.sqlite")
}

class DBInspectorHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_path = urllib.parse.urlparse(self.path)
        query_params = urllib.parse.parse_qs(parsed_path.query)
        
        db_key = query_params.get("db", [list(DATABASES.keys())[0]])[0]
        table_name = query_params.get("table", [None])[0]
        
        db_path = DATABASES.get(db_key)
        
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        
        html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Clinical Companion DB Inspector</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; background: #f4f6f9; color: #333; }}
                h1 {{ color: #0077b6; }}
                .nav {{ margin-bottom: 20px; }}
                .nav a, .tabs a {{ margin-right: 10px; padding: 8px 15px; background: #0077b6; color: white; text-decoration: none; border-radius: 4px; }}
                .tabs a.active {{ background: #023e8a; font-weight: bold; }}
                table {{ border-collapse: collapse; width: 100%; background: white; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }}
                th, td {{ border: 1px solid #ddd; padding: 10px; text-align: left; font-size: 13px; }}
                th {{ background: #0096c7; color: white; }}
                tr:nth-child(even) {{ background: #f8f9fa; }}
                .card {{ background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }}
            </style>
        </head>
        <body>
            <div class="card">
                <h1>🏥 Clinical Companion DB Visual Inspector</h1>
                
                <div class="nav tabs">
                    <strong>Databases:</strong> 
                    {' '.join([f'<a href="/?db={k}" class="{"active" if k == db_key else ""}">{k}</a>' for k in DATABASES.keys()])}
                </div>
        """
        
        if db_path and db_path.exists():
            try:
                with sqlite3.connect(db_path) as conn:
                    cursor = conn.cursor()
                    
                    # Get all tables
                    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
                    tables = [row[0] for row in cursor.fetchall() if not row[0].startswith('sqlite_')]
                    
                    html += f'<div class="nav" style="margin-top: 15px;"><strong>Tables in {db_key}:</strong> '
                    for t in tables:
                        active_style = "background: #2a9d8f;" if t == table_name else ""
                        html += f'<a href="/?db={urllib.parse.quote(db_key)}&table={t}" style="{active_style}">{t}</a>'
                    html += '</div>'
                    
                    if table_name and table_name in tables:
                        # Get schema columns
                        cursor.execute(f"PRAGMA table_info({table_name})")
                        columns = [row[1] for row in cursor.fetchall()]
                        
                        # Get row count
                        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
                        row_count = cursor.fetchone()[0]
                        
                        # Get first 50 rows
                        cursor.execute(f"SELECT * FROM {table_name} LIMIT 50")
                        rows = cursor.fetchall()
                        
                        html += f"<h3>Viewing Table: <code>{table_name}</code> (Total Rows: {row_count}, Showing first 50)</h3>"
                        html += "<table><tr>"
                        for col in columns:
                            html += f"<th>{col}</th>"
                        html += "</tr>"
                        
                        for row in rows:
                            html += "<tr>"
                            for val in row:
                                html += f"<td>{val if val is not None else '<span style=color:#999>NULL</span>'}</td>"
                            html += "</tr>"
                        html += "</table>"
                    else:
                        html += "<p><em>Please select a table above to view its contents.</em></p>"
                        
            except Exception as e:
                html += f"<p style='color: red;'>Error reading database: {e}</p>"
        else:
            html += f"<p style='color: red;'>Database file not found at {db_path}</p>"
            
        html += "</div></body></html>"
        self.wfile.write(html.encode("utf-8"))

def run_server(port=8080):
    server_address = ('', port)
    httpd = HTTPServer(server_address, DBInspectorHandler)
    print(f"🚀 Visual Database Inspector running at http://localhost:{port}")
    print("   (If using GitHub Codespaces, check the 'Ports' tab to open the URL in your browser)")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping inspector server.")

if __name__ == '__main__':
    run_server()