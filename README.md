# turyelectro
Repositorio de proyectos de Turyelectro.

## PostgreSQL en modo nativo (recomendado para este entorno)

Se migró la guía principal a **PostgreSQL nativo** (sin Docker), porque en este entorno el daemon de Docker no puede iniciar por restricciones de red/iptables.

### Archivos incluidos
- `.env.example`: variables de entorno para base, usuario, contraseña y puerto.
- `db/init/01_init.sql`: script de inicialización con tabla `clientes` y registro demo.
- `scripts/setup_postgres_native.sh`: instalación y configuración idempotente de PostgreSQL nativo.

### Cómo usarlo (nativo)

Valor por defecto: `POSTGRES_DB=TRANSPORTE`.

1. Copia variables de entorno:
   ```bash
   cp .env.example .env
   ```
2. Ejecuta el instalador/configurador nativo:
   ```bash
   sudo bash scripts/setup_postgres_native.sh
   ```
3. Prueba conexión:
   ```bash
   source .env
   PGPASSWORD="$POSTGRES_PASSWORD" psql -h localhost -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT now();"
   ```

### Notas
- El script crea/actualiza rol, crea base si no existe y ejecuta `db/init/01_init.sql`.
- Si cambias `POSTGRES_PORT`, el script actualiza `postgresql.conf` y reinicia el servicio.
