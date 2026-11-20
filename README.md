to get started with locally
Run the following command to start the docker database container

```
docker compose down -v && docker compose up -d db
```

Then run these commands to run the migrations

```
node database/scripts/migrate.ts database/migrations/001_configure_database.sql
```

```
node database/scripts/migrate.ts database/migrations/002_create_identity_tables.sql
```
