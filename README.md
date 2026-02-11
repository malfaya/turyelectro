# turyelectro
Repositorio de proyectos de Turyelectro.

## PostgreSQL con Docker Compose

Este repositorio ahora incluye una base PostgreSQL lista para desarrollo local mediante Docker Compose.

### Requisitos
- Docker
- Docker Compose (plugin `docker compose`)

### Variables de entorno (opcionales)
Puedes sobrescribir los valores por defecto exportando variables antes de levantar servicios:

- `POSTGRES_DB` (default: `turyelectro`)
- `POSTGRES_USER` (default: `turyelectro`)
- `POSTGRES_PASSWORD` (default: `turyelectro123`)
- `POSTGRES_PORT` (default: `5432`)

### Levantar PostgreSQL
```bash
docker compose up -d postgres
```

### Ejecutar migraciones iniciales
```bash
docker compose --profile tools run --rm migrate
```

Esto aplica los scripts SQL dentro de `migrations/` con la herramienta `migrate`.

### Detener servicios
```bash
docker compose down
```

### Eliminar datos persistidos
```bash
docker compose down -v
```
