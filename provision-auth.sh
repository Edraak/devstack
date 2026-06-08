set -e

echo "** Bring edraak-auth up **"
docker compose `echo ${DOCKER_COMPOSE_FILES}` up -d edraak-auth

echo "** Creating databases **"
echo "CREATE DATABASE IF NOT EXISTS edraak_auth CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" | docker exec -i edx.devstack.mysql mysql -uroot mysql

echo "** edraak-auth: Installing pip dependencies **"
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec edraak-auth bash -c 'pip install -r requirements.txt'

echo "** edraak-auth: Migrating databases **"
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec edraak-auth bash -c 'python manage.py migrate --noinput'

echo "** edraak-auth: Restarting **"
docker compose `echo ${DOCKER_COMPOSE_FILES}` restart edraak-auth
