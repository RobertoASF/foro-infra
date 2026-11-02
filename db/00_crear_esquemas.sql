-- Crea un esquema por microservicio en Oracle Autonomous Database.
-- Se ejecuta conectado como ADMIN y recibe las dos claves como parámetros.

SET VERIFY OFF

CREATE USER foro_usuarios IDENTIFIED BY "&1" QUOTA UNLIMITED ON DATA;
CREATE USER foro_publicaciones IDENTIFIED BY "&2" QUOTA UNLIMITED ON DATA;

GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE TO foro_usuarios, foro_publicaciones;
