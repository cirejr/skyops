--revoking create privilege to public schema so new user from public can't create
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON DATABASE skyops FROM PUBLIC

--appsecretpass needs to be changed afterwards
CREATE USER skyops_app WITH PASSWORD 'skyops_password';

--creating an owner for the db so to avoid app-user to perform drastic commands like drop
CREATE ROLE skyops_owner NOLOGIN;

--creating the apps db and assigning its owner to role previously created
CREATE DATABASE skyops OWNER skyops_owner;

--creating a readonly role for reportings, data exports, readonly replicas and the likes
CREATE ROLE readonly;
--allow the role to connect to the db
GRANT CONNECT ON DATABASE skyops TO readonly;

--grant access to the schema (but not object creation)
GRANT USAGE ON SCHEMA public TO readonly;

--allow the role to perform select queries from all existing tables, could be more restricted later
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;

--ensure readonly gets SELECT Privileges from future tables aswell
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly;

--create a read/write role
CREATE ROLE readwrite;

GRANT CONNECT ON DATABASE skyops TO readwrite;

GRANT USAGE, CREATE ON SCHEMA public TO readwrite;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO readwrite;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO readwrite;

GRANT readwrite TO skyops_app;

