# turyelectro
Repositorio de proyectos de Turyelectro

## PostgreSQL local con Docker

Se agregó una configuración lista para levantar PostgreSQL en local.

### Archivos incluidos
- `docker-compose.yml`: servicio `postgres` con volumen persistente y healthcheck.
- `.env.example`: variables de entorno de ejemplo para base, usuario, contraseña y puerto.
- `db/init/01_init.sql`: script de inicialización con tabla `clientes` y un registro demo.

### Cómo usarlo
1. Copia variables de entorno:
   ```bash
   cp .env.example .env
   ```
2. Levanta PostgreSQL:
   ```bash
   docker compose up -d
   ```
3. Verifica estado:
   ```bash
   docker compose ps
   ```
4. Conéctate con `psql`:
   ```bash
   PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -p ${POSTGRES_PORT:-5432} -U ${POSTGRES_USER:-turyelectro} -d ${POSTGRES_DB:-turyelectro}
   ```

### Notas
- El script en `db/init/` se ejecuta solo en la primera inicialización del volumen.
- Si quieres reinicializar la BD desde cero:
  ```bash
  docker compose down -v
  docker compose up -d
  ```
