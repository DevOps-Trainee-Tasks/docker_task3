CREATE EXTENSION IF NOT EXISTS vector;

SELECT format('CREATE ROLE %I LOGIN', :'dbuser')
WHERE NOT EXISTS (
  SELECT 1 FROM pg_roles WHERE rolname = :'dbuser'
) \gexec

SELECT format('ALTER ROLE %I PASSWORD %L', :'dbuser', :'dbpass') \gexec

SELECT format('GRANT USAGE, CREATE ON SCHEMA public TO %I', :'dbuser') \gexec