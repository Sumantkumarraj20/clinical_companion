import sqlite3
from pathlib import Path
from http.server import HTTPServer, BaseHTTPRequestHandler
import urllib.parse

DB_PATH = Path("assets/clinical_drugs.sqlite")

class GraphInspectorHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_path = urllib.parse.urlparse(self.path)
        query_params = urllib.parse.parse_qs(parsed_path.query)
        table_name = query_params.get("table", ["active_ingredients"])[0]
        
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        
        html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Clinical Knowledge Graph Inspector</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; margin: 20px; background: #f0f2f5; color: #1c1e21; }
                .card { background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
                h1 { color: #2c3e50; margin-top: 0;}
                .nav { margin-bottom: 20px; display: flex; gap: 10px; }
                .nav a { padding: 10px 16px; background: #e4e6eb; color: #050505; text-decoration: none; border-radius: 8px; font-weight: 500; transition: background 0.2s;}
                .nav a:hover { background: #d8dadf; }
                .nav a.active { background: #0064e0; color: white; }
                table { border-collapse: collapse; width: 100%; font-size: 13px; }
                th, td { border-bottom: 1px solid #ddd; padding: 12px 10px; text-align: left; }
                th { background: #f8f9fa; color: #606770; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; position: sticky; top: 0;}
                tr:hover { background: #f5f6f8; }
                .uuid { color: #888; font-family: monospace; font-size: 11px; }
            </style>
        </head>
        <body>
            <div class="card">
                <h1>🧬 Clinical Knowledge Graph</h1>
        """
        
        if DB_PATH.exists():
            try:
                with sqlite3.connect(DB_PATH) as conn:
                    cursor = conn.cursor()
                    tables = ["active_ingredients", "formulations", "brands", "drug_master"]
                    
                    html += '<div class="nav">'
                    for t in tables:
                        active_style = "active" if t == table_name else ""
                        html += f'<a href="/?table={t}" class="{active_style}">{t.replace("_", " ").title()}</a>'
                    html += '</div>'
                    
                    if table_name in tables:
                        # Get schema columns
                        cursor.execute(f"PRAGMA table_info({table_name})")
                        columns = [row[1] for row in cursor.fetchall()]
                        
                        # Get count
                        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
                        row_count = cursor.fetchone()[0]
                        
                        # Get rows
                        cursor.execute(f"SELECT * FROM {table_name} LIMIT 100")
                        rows = cursor.fetchall()
                        
                        html += f"<h3>Total Records: {row_count:,} <span style='color: #888; font-size: 14px; font-weight: normal;'>(Showing first 100)</span></h3>"
                        html += "<div style='overflow-x: auto;'><table><tr>"
                        for col in columns:
                            html += f"<th>{col}</th>"
                        html += "</tr>"
                        
                        for row in rows:
                            html += "<tr>"
                            for val in row:
                                str_val = str(val) if val is not None else '<span style="color:#aaa">NULL</span>'
                                # If it looks like a UUID, format it differently
                                if len(str_val) == 36 and '-' in str_val:
                                    html += f"<td class='uuid'>{str_val}</td>"
                                else:
                                    html += f"<td>{str_val}</td>"
                            html += "</tr>"
                        html += "</table></div>"
            except Exception as e:
                html += f"<p style='color: red;'>Error reading database: {e}</p>"
        else:
            html += f"<p style='color: red;'>Database not found at {DB_PATH}</p>"
            
        html += "</div></body></html>"
        self.wfile.write(html.encode("utf-8"))

if __name__ == '__main__':
    port = 8081
    server_address = ('', port)
    httpd = HTTPServer(server_address, GraphInspectorHandler)
    print(f"🚀 Graph Visualizer running at http://localhost:{port}")
    print("   Check your Codespaces 'Ports' tab and click 'Open in Browser'")
    httpd.serve_forever()