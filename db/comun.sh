#!/bin/bash
# Funciones que comparten cargar_bd.sh y migrar_v2.sh.
set -eo pipefail

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

# Devuelve un solo valor, sin encabezados ni espacios
consultar() {
  sqlplus -s /nolog <<EOF | tr -d '[:space:]'
WHENEVER SQLERROR EXIT FAILURE
CONNECT $1/"$2"@$DB_ALIAS
SET HEADING OFF FEEDBACK OFF PAGESIZE 0 VERIFY OFF
$3
EXIT
EOF
}

# Los reportes y baneos de ejemplo apuntan a temas y comentarios de ms-publicaciones.
# Como cada esquema genera sus propios id, se buscan antes de cargar moderación.
cargar_datos_moderacion() {
  local tema_spam comentario_ofensivo tema_liberado tema_reportado
  tema_spam=$(consultar foro_publicaciones "$DB_PUBLICACIONES_PASSWORD" \
    "SELECT id FROM temas WHERE titulo = 'Compra seguidores para tu canal de cartas';")
  comentario_ofensivo=$(consultar foro_publicaciones "$DB_PUBLICACIONES_PASSWORD" \
    "SELECT id FROM comentarios WHERE contenido LIKE 'Si no tienes plata no juegues%';")
  tema_liberado=$(consultar foro_publicaciones "$DB_PUBLICACIONES_PASSWORD" \
    "SELECT id FROM temas WHERE titulo LIKE '%guardar las cartas%';")
  tema_reportado=$(consultar foro_publicaciones "$DB_PUBLICACIONES_PASSWORD" \
    "SELECT id FROM temas WHERE titulo = 'Torneos de Mitos y Leyendas en Santiago';")

  for id in "$tema_spam" "$comentario_ofensivo" "$tema_liberado" "$tema_reportado"; do
    if [[ ! "$id" =~ ^[0-9]+$ ]]; then
      echo "No se encontraron los temas o comentarios de ejemplo en publicaciones"
      exit 1
    fi
  done

  echo "Id usados en moderación: $tema_spam $comentario_ofensivo $tema_liberado $tema_reportado"
  ejecutar foro_moderacion "$DB_MODERACION_PASSWORD" \
    "@/sql/moderacion/02_datos.sql $tema_spam $comentario_ofensivo $tema_liberado $tema_reportado"
}
