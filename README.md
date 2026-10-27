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

To run the tests (requires the database to be running): `./mvnw verify`

## Configuration
All settings have defaults matching `docker-compose.yml` and can be overridden with environment variables:

| Variable | Default | Purpose |
| --- | --- | --- |
| `DB_URL` | `jdbc:postgresql://localhost:5432/battletechSearch` | JDBC URL |
| `DB_USER` | `battletech` | Database user |
| `DB_PASSWORD` | `battletech` | Database password |
| `MEGAMEK_MECHS_PATH` | _(empty)_ | MegaMek `data/mechfiles/mechs` directory, only needed to re-import units |
| `MEGAMEK_VEHICLES_PATH` | _(empty)_ | MegaMek `data/mechfiles/vehicles` directory, only needed to re-import units |
| `RECOGNITION_GUIDE_PDF` | _(empty)_ | Recognition guide PDF for the experimental PDF import |

The MegaMek unit files come from https://github.com/MegaMek/megamek.

## Using an existing database
`V1_0__initialize.sql` was edited to remove hard-coded owner/grant statements, which changes its Flyway checksum. If your database was created before that change, run once:

```
DB_URL=jdbc:postgresql://localhost:5432/battletechSearch DB_USER=<user> DB_PASSWORD=<password> ./mvnw flyway:repair
```

Or point the app at a fresh database (e.g. the Docker one) instead.
