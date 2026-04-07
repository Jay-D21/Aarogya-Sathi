import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import sys

def main():
    try:
        # Connect to default 'postgres' database
        print("Connecting to default 'postgres' database...")
        conn = psycopg2.connect(dbname='postgres', user='postgres', password='Jay', host='localhost', port='5432')
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cur = conn.cursor()
        
        db_name = 'aarogya_sathi'

        # Check if exists
        cur.execute(f"SELECT 1 FROM pg_catalog.pg_database WHERE datname = '{db_name}'")
        exists = cur.fetchone()
        
        if exists:
            print(f"Database {db_name} already exists. Dropping it...")
            # Terminate existing connections before dropping
            cur.execute(f'''
                SELECT pg_terminate_backend(pg_stat_activity.pid)
                FROM pg_stat_activity
                WHERE pg_stat_activity.datname = '{db_name}'
                  AND pid <> pg_backend_pid();
            ''')
            cur.execute(f"DROP DATABASE {db_name}")
            
        print(f"Creating database {db_name}...")
        cur.execute(f"CREATE DATABASE {db_name}")
        print("Database created successfully.")
            
        cur.close()
        conn.close()

        print("Connecting to the new database to enable extensions...")
        # Connect to the new database to create extensions
        conn = psycopg2.connect(dbname=db_name, user='postgres', password='Jay', host='localhost', port='5432')
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cur = conn.cursor()
        
        print("Enabling uuid-ossp extension...")
        cur.execute('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";')
        print("Enabling pgcrypto extension...")
        cur.execute('CREATE EXTENSION IF NOT EXISTS "pgcrypto";')
        print("Extensions enabled successfully.")
        
        cur.close()
        conn.close()

    except Exception as e:
        print(f"Error creating database: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
