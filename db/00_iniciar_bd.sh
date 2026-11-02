#!/bin/bash
# Crea los esquemas y carga las tablas de cada microservicio.
# El contenedor de Oracle lo ejecuta solo la primera vez que arranca.
set -e

export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
BD="//localhost:1521/FREEPDB1"

sqlplus -s / as sysdba <<EOF
WHENEVER SQLERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = FREEPDB1;
CREATE USER foro_usuarios IDENTIFIED BY "${DB_USUARIOS_PASSWORD}" QUOTA UNLIMITED ON USERS;
CREATE USER foro_publicaciones IDENTIFIED BY "${DB_PUBLICACIONES_PASSWORD}" QUOTA UNLIMITED ON USERS;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE TO foro_usuarios, foro_publicaciones;
EXIT
EOF

ejecutar() {
  sqlplus -s "$1/\"$2\"@$BD" <<EOF
WHENEVER SQLERROR EXIT FAILURE
@$3
EXIT
EOF
}

ejecutar foro_usuarios "$DB_USUARIOS_PASSWORD" /sql/usuarios/01_tablas.sql
ejecutar foro_usuarios "$DB_USUARIOS_PASSWORD" /sql/usuarios/02_datos.sql
ejecutar foro_publicaciones "$DB_PUBLICACIONES_PASSWORD" /sql/publicaciones/01_tablas.sql
ejecutar foro_publicaciones "$DB_PUBLICACIONES_PASSWORD" /sql/publicaciones/02_datos.sql
