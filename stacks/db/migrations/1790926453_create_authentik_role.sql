-- migrate:up
CREATE ROLE authentik_user WITH LOGIN PASSWORD 'authentik' NOSUPERUSER NOCREATEDB NOCREATEROLE;
-- Ownership de do — ye sabse important step hai
ALTER DATABASE authentik_db OWNER TO authentik_user;
ALTER SCHEMA public OWNER TO authentik_user;
-- Jo objects pehle se maujood hain unka ownership bhi transfer karo
-- (agar koi existing tables/sequences already kisi aur user ke under hain)
GRANT ALL PRIVILEGES ON DATABASE authentik_db TO authentik_user;
GRANT ALL PRIVILEGES ON SCHEMA public TO authentik_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO authentik_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO authentik_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO authentik_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO authentik_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO authentik_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON FUNCTIONS TO authentik_user;
-- migrate:down
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public
FROM authentik_user;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public
FROM authentik_user;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public
FROM authentik_user;
DROP ROLE IF EXISTS authentik_user;
