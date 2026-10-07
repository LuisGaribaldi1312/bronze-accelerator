-- init.sql
-- Este archivo se ejecuta una vez al iniciar PostgreSQL en el contenedor de desarrollo.
-- Configura extensiones y roles base.

-- Extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Rol para AppSheet (con permisos limitados)
-- NOTA: En producción, AppSheet se conectará con este rol que tendrá
-- permisos READWRITE solo en las tablas necesarias, NUNCA acceso de admin.
CREATE ROLE appsheet_user WITH LOGIN PASSWORD 'changeme_appsheets_dev_only';
GRANT CONNECT ON DATABASE codigodb TO appsheet_user;

-- Schema principal
CREATE SCHEMA IF NOT EXISTS codigo AUTHORIZATION codigodb;
SET search_path TO codigo;

-- Otorgar permisos de esquema
GRANT USAGE ON SCHEMA codigo TO appsheet_user;
GRANT USAGE ON SCHEMA codigo TO codigodb;
