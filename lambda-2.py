import psycopg2

def lambda_handler(event, context):
    # Configure these with your actual values.
    db_host = 'hostname'
    db_port = 'port'
    db_name = 'database_name'
    db_user = 'username'
    db_password = 'password'
    
    # Connect to your PostgreSQL database.
    conn = psycopg2.connect(
        dbname=db_name,
        user=db_user,
        password=db_password,
        host=db_host,
        port=db_port
    )

    try:
        # Open a cursor to perform database operations.
        cur = conn.cursor()
        
        # Define the new schema name.
        old_public_schema = 'old_public'  # Replace with your desired name.
        
        # Rename the 'public' schema.
        cur.execute(f'ALTER SCHEMA public RENAME TO {old_public_schema}')
        
        # Create a new 'public' schema.
        cur.execute('CREATE SCHEMA public')
        
        # Grant USAGE and CREATE privileges to the 'public' schema.
        cur.execute('GRANT USAGE, CREATE ON SCHEMA public TO PUBLIC')
        
        # Migrate all objects from the old public schema to the new public schema.
        for obj_type in ['TABLE', 'SEQUENCE', 'VIEW']:
            cur.execute(f"""
                DO $$ DECLARE r record;
                BEGIN
                    FOR r IN (SELECT tablename AS name FROM pg_tables WHERE schemaname = '{old_public_schema}')
                    LOOP
                        EXECUTE 'ALTER {obj_type} {old_public_schema}.' || quote_ident(r.name) || ' SET SCHEMA public';
                    END LOOP;
                END $$;
            """)
        # Commit the transaction.
        cur.execute('COMMIT')

    except Exception as e:
        print("Error while renaming schema, creating new 'public' schema, and moving objects: ", e)
        cur.execute('ROLLBACK')

    finally:
        # Close the cursor and the connection.
        cur.close()
        conn.close()
