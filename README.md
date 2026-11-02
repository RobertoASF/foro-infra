# Foro en línea: infraestructura

Este repositorio levanta el backend completo del foro con un solo comando. Aquí están el `docker-compose`, la carga inicial de Oracle y la colección de Bruno con las pruebas de todos los endpoints.

El sistema se divide en tres repositorios:

| Repositorio | Contenido |
|---|---|
| `foro-ms-usuarios` | Usuarios, roles e inicio de sesión |
| `foro-ms-publicaciones` | Categorías, temas, comentarios y búsqueda |
| `foro-infra` | Este repositorio |

## Arquitectura

```mermaid
flowchart LR
    C[Cliente: Bruno o un frontend] -->|1. login| U[ms-usuarios :8081]
    U -->|2. token JWT| C
    C -->|3. peticiones con token| P[ms-publicaciones :8082]
    subgraph Oracle [Oracle FREEPDB1]
        EU[(FORO_USUARIOS)]
        EP[(FORO_PUBLICACIONES)]
    end
    U --> EU
    P --> EP
```

- Cada microservicio es dueño de sus datos y tiene su propio esquema en Oracle.
- `ms-usuarios` entrega un token JWT firmado con el id, el nombre y el rol del usuario.
- `ms-publicaciones` valida ese token con el mismo secreto, así que no necesita llamar a `ms-usuarios`. Si uno de los dos se detiene, el otro sigue funcionando.
- Cada tema y comentario guarda el id y el nombre de su autor. Ese id no lleva clave foránea porque el usuario vive en otro esquema.

## Modelo de datos

```mermaid
erDiagram
    ROLES ||--o{ USUARIOS : tiene
    CATEGORIAS ||--o{ TEMAS : agrupa
    TEMAS ||--o{ COMENTARIOS : recibe

    ROLES {
        number id PK
        varchar nombre UK
        varchar descripcion
    }
    USUARIOS {
        number id PK
        varchar nombre_usuario UK
        varchar email UK
        varchar password_hash
        number rol_id FK
        number activo
        timestamp fecha_creacion
    }
    CATEGORIAS {
        number id PK
        varchar nombre UK
        varchar descripcion
    }
    TEMAS {
        number id PK
        varchar titulo
        varchar contenido
        number categoria_id FK
        number autor_id
        varchar autor_nombre
        timestamp fecha_creacion
        timestamp fecha_actualizacion
    }
    COMENTARIOS {
        number id PK
        number tema_id FK
        varchar contenido
        number autor_id
        varchar autor_nombre
        timestamp fecha_creacion
        timestamp fecha_actualizacion
    }
```

`ROLES` y `USUARIOS` están en `FORO_USUARIOS`. Las otras tres tablas están en `FORO_PUBLICACIONES`.

## Roles

| Permiso | USUARIO | MODERADOR | ADMIN |
|---|---|---|---|
| Publicar, comentar y editar lo propio | Sí | Sí | Sí |
| Borrar temas y comentarios propios | Sí | Sí | Sí |
| Borrar temas y comentarios de otros | No | Sí | Sí |
| Gestionar categorías | No | No | Sí |
| Gestionar usuarios y roles | No | No | Sí |

## Cómo levantarlo

Necesitas Docker Desktop y los tres repositorios en la misma carpeta:

```
carpeta/
├── foro-infra/
├── foro-ms-usuarios/
└── foro-ms-publicaciones/
```

Dentro de `foro-infra`, copia el archivo de variables y cambia sus valores:

```bash
cp .env.example .env
```

Luego levanta todo:

```bash
docker compose up -d --build --wait
```

La primera vez demora unos minutos porque descarga las imágenes y compila los microservicios. Oracle crea los esquemas, las tablas y los datos iniciales solo en ese primer arranque.

| Servicio | Dirección |
|---|---|
| ms-usuarios | http://localhost:8081 |
| ms-publicaciones | http://localhost:8082 |
| Oracle | `localhost:1521`, servicio `FREEPDB1` |

Para detenerlo sin perder los datos:

```bash
docker compose down
```

Para borrar también la base y partir desde cero:

```bash
docker compose down -v
```

## Usuarios de prueba

Todos usan la clave `Foro2026*`.

| Usuario | Rol |
|---|---|
| `admin` | ADMIN |
| `moderador` | MODERADOR |
| `camila` | USUARIO |
| `diego` | USUARIO |

## Pruebas con Bruno

La colección está en la carpeta `bruno`. Tiene 43 solicitudes y cada una revisa su respuesta, incluidos los casos de error 400, 401, 403, 404 y 409.

1. Abre Bruno y elige **Open Collection** con la carpeta `bruno`.
2. Selecciona el ambiente `local`.
3. Ejecuta primero la carpeta `01 Inicio de sesion`, porque ahí se guardan los tokens que usan las demás.

También se puede ejecutar completa desde la terminal, dentro de la carpeta `bruno`:

```bash
npx @usebruno/cli@4.3.0 run -r --env local
```

## Revisar los datos en Oracle

Con cualquier cliente SQL, usa los datos de conexión de arriba con el usuario `foro_usuarios` o `foro_publicaciones` y la clave definida en `.env`.

También se puede entrar desde el contenedor:

```bash
docker exec -it foro-oracle sqlplus foro_publicaciones@//localhost/FREEPDB1
```

```sql
SELECT t.id, t.titulo, c.nombre AS categoria, t.autor_nombre
FROM temas t JOIN categorias c ON c.id = t.categoria_id
ORDER BY t.id;
```
