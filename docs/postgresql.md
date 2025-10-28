# PostgreSQL setup guide

## Install Docker
   https://docs.docker.com/get-started/get-docker/

## Start PostgreSQL using Docker
   ```bash
   docker compose pull
   docker compose up -d postgresql
   ```

## Configure PostgreSQL

Check the connection, if it works, then there is no need to configure.
```bash
psql -U postgres -h localhost
```

1. Connect to container
    ```bash
    docker exec -it simple_drive-postgresql-1 bash
    ```
2. Add config to allow external connections
    ```bash
    echo "host all all all md5" >> /var/lib/postgresql/18/docker/pg_hba.conf
    ```
3. Restart the PostgreSQL container to apply changes
    ```bash
    docker compose down
    docker compose up -d postgresql
    ```
