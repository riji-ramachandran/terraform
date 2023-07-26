DO
$$
DECLARE
    row record;
BEGIN
    -- For each table in the current schema...
    FOR row IN SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        -- ...move it to the new schema
        EXECUTE 'ALTER TABLE public.' || quote_ident(row.tablename) || ' SET SCHEMA new_schema;';
    END LOOP;

    -- For each sequence in the current schema...
    FOR row IN SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'public'
    LOOP
        -- ...move it to the new schema
        EXECUTE 'ALTER SEQUENCE public.' || quote_ident(row.sequence_name) || ' SET SCHEMA new_schema;';
    END LOOP;

    -- For each view in the current schema...
    FOR row IN SELECT table_name FROM information_schema.views WHERE table_schema = 'public'
    LOOP
        -- ...move it to the new schema
        EXECUTE 'ALTER VIEW public.' || quote_ident(row.table_name) || ' SET SCHEMA new_schema;';
    END LOOP;

    -- For each materialized view in the current schema...
    FOR row IN SELECT matviewname FROM pg_matviews WHERE schemaname = 'public'
    LOOP
        -- ...move it to the new schema
        EXECUTE 'ALTER MATERIALIZED VIEW public.' || quote_ident(row.matviewname) || ' SET SCHEMA new_schema;';
    END LOOP;
    
    -- For each function in the current schema...
    FOR row IN SELECT routine_name FROM information_schema.routines WHERE specific_schema='public'
    LOOP
        -- ...move it to the new schema
        EXECUTE 'ALTER FUNCTION public.' || quote_ident(row.routine_name) || ' SET SCHEMA new_schema;';
    END LOOP;

    -- For each type in the current schema...
    FOR row IN SELECT typname FROM pg_type WHERE typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
    LOOP
        -- ...move it to the new schema
        EXECUTE 'ALTER TYPE public.' || quote_ident(row.typname) || ' SET SCHEMA new_schema;';
    END LOOP;

    FOR row IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tabletype = 'f'
    LOOP
        -- ...move it to the new schema
        EXECUTE 'ALTER FOREIGN TABLE public.' || quote_ident(row.tablename) || ' SET SCHEMA new_schema;';
    END LOOP;

END
$$;
