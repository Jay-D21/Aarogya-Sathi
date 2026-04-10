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
        db_user = 'arogya_user'
        db_pass = 'arogya_dev_password'

        # Check if user exists, if not create
        cur.execute(f"SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = '{db_user}'")
        user_exists = cur.fetchone()
        if not user_exists:
            print(f"Creating user {db_user}...")
            cur.execute(f"CREATE USER {db_user} WITH PASSWORD '{db_pass}'")
            cur.execute(f"ALTER USER {db_user} CREATEDB") # Allow creating DB if needed
        else:
            print(f"User {db_user} already exists. Updating password...")
            cur.execute(f"ALTER USER {db_user} WITH PASSWORD '{db_pass}'")

        # Check if database exists
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
        cur.execute(f"CREATE DATABASE {db_name} OWNER {db_user}")
        print("Database created successfully.")
            
        cur.close()
        conn.close()

        print("Connecting to the new database to enable extensions...")
        # Connect to the new database to create extensions (needs superuser usually)
        conn = psycopg2.connect(dbname=db_name, user='postgres', password='Jay', host='localhost', port='5432')
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cur = conn.cursor()
        
        print("Enabling uuid-ossp extension...")
        cur.execute('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";')
        print("Enabling pgcrypto extension...")
        cur.execute('CREATE EXTENSION IF NOT EXISTS "pgcrypto";')
        
        print("Granting permissions to arogya_user...")
        cur.execute(f"GRANT ALL PRIVILEGES ON DATABASE {db_name} TO {db_user}")
        cur.execute(f"GRANT ALL PRIVILEGES ON SCHEMA public TO {db_user}")
        cur.execute(f"ALTER SCHEMA public OWNER TO {db_user}")
        
        print("Extensions enabled and permissions granted successfully.")
        
        cur.close()
        conn.close()

    except Exception as e:
        print(f"Error creating database: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
