#!/bin/bash
# Crea los esquemas en Oracle Cloud y carga las tablas de cada microservicio.
# Es para una base nueva. Se ejecuta una sola vez con: docker compose run --rm cargar-bd
set -e
source /scripts/comun.sh

echo "Creando esquemas..."
ejecutar admin "$ORACLE_ADMIN_PASSWORD" \
  "@/scripts/00_crear_esquemas.sql \"$DB_USUARIOS_PASSWORD\" \"$DB_PUBLICACIONES_PASSWORD\" \"$DB_MODERACION_PASSWORD\""

echo "Cargando tablas de usuarios..."
ejecutar foro_usuarios "$DB_USUARIOS_PASSWORD" @/sql/usuarios/01_tablas.sql
ejecutar foro_usuarios "$DB_USUARIOS_PASSWORD" @/sql/usuarios/02_datos.sql

echo "Cargando tablas de publicaciones..."
ejecutar foro_publicaciones "$DB_PUBLICACIONES_PASSWORD" @/sql/publicaciones/01_tablas.sql
ejecutar foro_publicaciones "$DB_PUBLICACIONES_PASSWORD" @/sql/publicaciones/02_datos.sql
ejecutar foro_publicaciones "$DB_PUBLICACIONES_PASSWORD" @/sql/publicaciones/03_contenido_baneado.sql

echo "Cargando tablas de moderación..."
ejecutar foro_moderacion "$DB_MODERACION_PASSWORD" @/sql/moderacion/01_tablas.sql
cargar_datos_moderacion

echo "Base de datos lista."
