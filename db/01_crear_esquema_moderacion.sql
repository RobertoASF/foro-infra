-- Crea solo el esquema de ms-moderacion en una base que ya tiene la versión 1.
-- Se ejecuta conectado como ADMIN y recibe la clave como parámetro.

SET VERIFY OFF

CREATE USER foro_moderacion IDENTIFIED BY "&1" QUOTA UNLIMITED ON DATA;

GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE TO foro_moderacion;
