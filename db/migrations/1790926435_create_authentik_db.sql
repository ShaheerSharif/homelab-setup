-- migrate:up transaction:false
CREATE DATABASE authentik_db;
-- migrate:down
DROP DATABASE IF EXISTS authentik_db;
