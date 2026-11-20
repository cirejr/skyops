
CREATE ROLE skyops_owner NOLOGIN;
CREATE ROLE readonly;
CREATE ROLE readwrite;

CREATE DATABASE skyops OWNER skyops_owner;
CREATE USER skyops_app WITH PASSWORD 'skyops_password';

GRANT readwrite TO skyops_app;
CREATE ROLE skyops_migrator LOGIN NOINHERIT PASSWORD 'skyops_migrator_password';
GRANT skyops_owner TO skyops_migrator;
GRANT CONNECT ON DATABASE skyops TO skyops_migrator