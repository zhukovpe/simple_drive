# PostgeSQL setup guide

1. **Install Docker**
   https://docs.docker.com/get-started/get-docker/

2. **Start PostgreSQL using Docker**
   ```bash
   docker compose pull
   docker compose up -d postgresql
   ```

3. **Configure PostgreSQL**

   connect to container
   ```bash
   docker exec -it simple_drive-postgresql-1 bash
   ```
   add config to allow external connections
   ```bash
   echo "host all all all md5" >> /var/lib/postgresql/data/18/docker/pg_hba.conf
   ```
   create user
   ```
   psql -U admin
   create role postgres with login createdb password 'postgres';
   ```
   Restart the PostgreSQL container to apply changes.
