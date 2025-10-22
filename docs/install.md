# Installation

1. ruby 3.4.7
2. postgresql
  ```
  docker compose pull
  docker compose up -d postgresql
  docker exec -it simple_drive-postgresql-1 bash
  echo "host all all all md5" >> /var/lib/postgresql/data/18/docker/pg_hba.conf

  psql -U admin
  create role postgres with login createdb password 'postgres';
  ```
  restart postgres to take effect
3. bundle install
4. bundle exec rails server
  http://localhost:3000/up
