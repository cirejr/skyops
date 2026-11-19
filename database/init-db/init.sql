
CREATE ROLE skyops_owner NOLOGIN;
CREATE ROLE readonly;
CREATE ROLE readwrite;
CREATE DATABASE skyops OWNER skyops_owner;
CREATE USER skyops_app WITH PASSWORD 'skyops_password';
