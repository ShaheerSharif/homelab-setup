-- migrate:up transaction:false
CREATE DATABASE npm_db;
-- migrate:down
DROP DATABASE IF EXISTS npm_db;
