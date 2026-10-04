-- migrate:up
CREATE ROLE paperless_user WITH LOGIN PASSWORD 'paperless' NOSUPERUSER NOCREATEDB NOCREATEROLE;
-- Ownership de do — ye sabse important step hai
ALTER DATABASE paperless_db OWNER TO paperless_user;
ALTER SCHEMA public OWNER TO paperless_user;
-- Jo objects pehle se maujood hain unka ownership bhi transfer karo
-- (agar koi existing tables/sequences already kisi aur user ke under hain)
GRANT ALL PRIVILEGES ON DATABASE paperless_db TO paperless_user;
GRANT ALL PRIVILEGES ON SCHEMA public TO paperless_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO paperless_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO paperless_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO paperless_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO paperless_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO paperless_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON FUNCTIONS TO paperless_user;
-- migrate:down
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public
FROM paperless_user;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public
FROM paperless_user;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public
FROM paperless_user;
DROP ROLE IF EXISTS paperless_user;
