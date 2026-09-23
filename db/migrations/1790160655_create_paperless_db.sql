-- migrate:up transaction:false
CREATE DATABASE paperless_db;
-- migrate:down
DROP DATABASE IF EXISTS paperless_db;
