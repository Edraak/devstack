#!/usr/bin/env bash
set -e

echo "Provisioning edraak-auth service..."

docker compose `echo ${DOCKER_COMPOSE_FILES}` up -d edraak-auth

docker exec -i edx.devstack.mysql mysql -uroot -e "
    CREATE DATABASE IF NOT EXISTS edraak_auth CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    GRANT ALL PRIVILEGES ON edraak_auth.* TO 'root'@'%';
    FLUSH PRIVILEGES;
"

echo "** edraak-auth: Installing pip dependencies **"
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec edraak-auth bash -c 'pip install -r requirements.txt'

echo "** edraak-auth: Migrating databases **"
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec edraak-auth bash -c 'python manage.py migrate --noinput'

echo "** edraak-auth: Restarting **"
docker compose `echo ${DOCKER_COMPOSE_FILES}` restart edraak-auth

echo "edraak-auth provisioning complete."
