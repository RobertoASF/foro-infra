#!/bin/bash
# Crea los esquemas en Oracle Cloud y carga las tablas de cada microservicio.
# Se ejecuta una sola vez con: docker compose run --rm cargar-bd
set -e

export NLS_LANG=AMERICAN_AMERICA.AL32UTF8

# sqlnet.ora apunta a una ruta interna del cliente, por eso se usa una copia con la ruta real
mkdir -p /tmp/wallet
cp /wallet/* /tmp/wallet/
sed -i 's|?/network/admin|/tmp/wallet|' /tmp/wallet/sqlnet.ora
export TNS_ADMIN=/tmp/wallet

# La clave va dentro de SQL*Plus para que no quede a la vista en la lista de procesos
ejecutar() {
  sqlplus -s /nolog <<EOF
WHENEVER SQLERROR EXIT FAILURE
CONNECT $1/"$2"@$DB_ALIAS
$3
EXIT
EOF
}

echo "Creando esquemas..."
ejecutar admin "$ORACLE_ADMIN_PASSWORD" "@/scripts/00_crear_esquemas.sql \"$DB_USUARIOS_PASSWORD\" \"$DB_PUBLICACIONES_PASSWORD\""

echo "Cargando tablas de usuarios..."
ejecutar foro_usuarios "$DB_USUARIOS_PASSWORD" @/sql/usuarios/01_tablas.sql
ejecutar foro_usuarios "$DB_USUARIOS_PASSWORD" @/sql/usuarios/02_datos.sql

echo "Cargando tablas de publicaciones..."
ejecutar foro_publicaciones "$DB_PUBLICACIONES_PASSWORD" @/sql/publicaciones/01_tablas.sql
ejecutar foro_publicaciones "$DB_PUBLICACIONES_PASSWORD" @/sql/publicaciones/02_datos.sql

echo "Base de datos lista."
