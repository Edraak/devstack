set -e

echo "** Bringing up **"
docker-compose $DOCKER_COMPOSE_FILES up -d mysql edraak_programs edraak_marketing

echo "** Creating databases **"
docker exec -i edx.devstack.mysql mysql -uroot mysql < provision-edraak.sql

echo "** Marketing **"
./provision-edraak-marketing.sh

echo "** Programs **"
./provision-edraak-programs.sh
