set -e

echo "** Bring Marketing up **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` up -d mktg

echo "** Creating databases **"
echo "CREATE DATABASE IF NOT EXISTS marketingsite;" | docker exec -i edx.devstack.mysql8 mysql -uroot mysql

echo "** Marketing: Copy cacheed files to code dir **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec mktg bash -c 'cp -Rn /cache/* /app/.'
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec mktg bash -c 'pip3 install -r requirements.txt'

echo "** Marketing: Migrating databases **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec mktg bash -c 'python3.8 manage.py migrate --settings=marketingsite.envs.dev'

echo "** Marketing: Compiling assets **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec mktg bash -c 'rm -rf node_modules/'
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec mktg bash -c 'yarn'
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec mktg bash -c 'npm run dev'

echo "** Marketing: Restarting **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` restart mktg
