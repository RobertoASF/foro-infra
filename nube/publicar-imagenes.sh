#!/bin/bash
# Construye las cuatro imágenes y las sube a Docker Hub.
# Antes hay que iniciar sesión con: docker login -u robertoasf
# Se ejecuta desde la carpeta que contiene los repositorios: bash foro-infra/nube/publicar-imagenes.sh
set -e
USUARIO=${1:-robertoasf}

publicar() {
  local imagen="$USUARIO/$1"
  echo "== $imagen:$2"
  docker build -t "$imagen:$2" -t "$imagen:latest" "$3"
  docker push "$imagen:$2"
  docker push "$imagen:latest"
}

publicar foro-ms-usuarios 1.1.0 foro-ms-usuarios
publicar foro-ms-publicaciones 1.1.0 foro-ms-publicaciones
publicar foro-ms-moderacion 1.0.0 foro-ms-moderacion
publicar foro-frontend 1.0.0 foro-frontend
