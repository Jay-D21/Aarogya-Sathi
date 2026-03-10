import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import sys

try:
    # Connect to default 'postgres' database
    conn = psycopg2.connect(dbname='postgres', user='postgres', password='Jay', host='localhost', port='5432')
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()
    
    # Check if exists
    cur.execute("SELECT 1 FROM pg_catalog.pg_database WHERE datname = 'arogya_sathi_mvp'")
    exists = cur.fetchone()
    
    if not exists:
        print("Creating database arogya_sathi_mvp...")
        cur.execute("CREATE DATABASE arogya_sathi_mvp")
        print("Database created successfully.")
    else:
        print("Database already exists.")
        
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error creating database: {e}")
    sys.exit(1)
