GRANT USAGE ON SCHEMA public TO PUBLIC;

GRANT CREATE ON SCHEMA public TO PUBLIC;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO PUBLIC;
