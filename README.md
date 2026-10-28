# BattletechSearch
A micro search engine for Battletech units using natural-language queries, e.g.

```
light units with at most 2 mediumlaser and at least 1 srm6
```

## Requirements
- JDK 21 or newer
- Docker (for the local PostgreSQL database), or your own PostgreSQL install

Maven does not need to be installed; use the included wrapper (`./mvnw`, or `mvnw.cmd` on Windows).

## Running locally
1. Start the database:
   ```
   docker compose up -d
   ```
   This creates a `battletechSearch` database with user/password `battletech`/`battletech`.
1. Start the application:
   ```
   ./mvnw spring-boot:run
   ```
   The ANTLR grammar is compiled automatically during the build, and Flyway creates the schema and loads the unit data on first start.
1. Open http://localhost:8080/

To run the tests: `./mvnw verify`. Docker must be running, but `docker compose` doesn't need to be: the tests start their own throwaway Postgres via Testcontainers and load the baseline data into it.

The build also downloads Node into `target/node` and runs the search box's JavaScript tests (`src/test/js`). Nothing else needs installing. Skip them with `-Dskip.npm`.

## Configuration
All settings have defaults matching `docker-compose.yml` and can be overridden with environment variables:

| Variable | Default | Purpose |
| --- | --- | --- |
| `DB_URL` | `jdbc:postgresql://localhost:5432/battletechSearch` | JDBC URL |
| `DB_USER` | `battletech` | Database user |
| `DB_PASSWORD` | `battletech` | Database password |
| `MEGAMEK_MECHS_PATH` | _(empty)_ | mm-data `data/mekfiles/meks` directory, only needed to import units |
| `MEGAMEK_VEHICLES_PATH` | _(empty)_ | mm-data `data/mekfiles/vehicles` directory, only needed to import units |
| `RECOGNITION_GUIDE_PDF` | _(empty)_ | Recognition guide PDF for the experimental PDF import |
| `MANAGEMENT_PORT` | `8081` | Port for the admin endpoints (always bound to `127.0.0.1`) |

The MegaMek unit files come from https://github.com/MegaMek/mm-data (`data/mekfiles/meks` and `data/mekfiles/vehicles`).

## Admin endpoints
Admin actions are [Spring Boot Actuator](https://docs.spring.io/spring-boot/reference/actuator/endpoints.html) endpoints on a separate port that only listens on `127.0.0.1`. Other machines can't connect to it, and the public port (8080) only serves search.

| Endpoint | Purpose |
| --- | --- |
| `GET http://localhost:8081/actuator/health` | Health check |
| `POST http://localhost:8081/actuator/import` | Run an import. Body: `{"source": "mechs"}` or `{"source": "vehicles"}` (from `MEGAMEK_MECHS_PATH` / `MEGAMEK_VEHICLES_PATH`; re-running updates units instead of duplicating them), or `{"source": "recognition-guide"}` (experimental PDF import) |
| `POST http://localhost:8081/actuator/slang` | Add slang for an equipment name. Body: `{"equipmentName": "mediumlaser", "terms": "ml, medium laser"}`. Terms are comma-separated. |

For example:

```
curl -X POST http://localhost:8081/actuator/slang -H "Content-Type: application/json" \
  -d '{"equipmentName": "mediumlaser", "terms": "ml, medium laser"}'
```

## Using an existing database
`V1_0__initialize.sql` was edited to remove hard-coded owner/grant statements, which changes its Flyway checksum. If your database was created before that change, run once:

```
DB_URL=jdbc:postgresql://localhost:5432/battletechSearch DB_USER=<user> DB_PASSWORD=<password> ./mvnw flyway:repair
```

Or point the app at a fresh database (e.g. the Docker one) instead.
