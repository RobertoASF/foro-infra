#!/bin/bash
# Lleva una base de la versión 1 (semana 2) a la versión 2.
# Agrega el esquema de moderación y la columna baneado en publicaciones.
# Se ejecuta una sola vez con: docker compose run --rm migrar-bd
set -e
source /scripts/comun.sh

echo "Creando esquema de moderación..."
ejecutar admin "$ORACLE_ADMIN_PASSWORD" "@/scripts/01_crear_esquema_moderacion.sql \"$DB_MODERACION_PASSWORD\""

echo "Actualizando tablas de publicaciones..."
ejecutar foro_publicaciones "$DB_PUBLICACIONES_PASSWORD" @/sql/publicaciones/migraciones/v1_a_v2.sql
ejecutar foro_publicaciones "$DB_PUBLICACIONES_PASSWORD" @/sql/publicaciones/03_contenido_baneado.sql

echo "Cargando tablas de moderación..."
ejecutar foro_moderacion "$DB_MODERACION_PASSWORD" @/sql/moderacion/01_tablas.sql
cargar_datos_moderacion

echo "Migración lista."
