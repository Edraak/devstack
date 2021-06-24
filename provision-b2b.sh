set -e

echo "** bring b2b container up **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` up -d b2b


echo "** Creating databases **"
echo "CREATE DATABASE IF NOT EXISTS b2b;" | docker exec -i edx.devstack.mysql mysql -uroot mysql

echo "** b2b: Copy cacheed files to code dir **"
#docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec b2b bash -c 'cp -Rn /cache/* /app/.'
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec b2b bash -c 'pip install -r requirements.txt'

echo "** b2b: Migrating databases **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec b2b bash -c 'python manage.py migrate --settings=edraakprograms.dev'

echo "** b2b: Compiling assets **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec b2b bash -c 'npm rebuild node-sass'
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec b2b bash -c 'chown -R root ~/.npm'
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec b2b bash -c 'npm install'
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec b2b bash -c 'npm run dev'
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec b2b bash -c 'python manage.py collectstatic --ignore="*.less" --ignore="*.scss" --noinput --clear --settings=edraakprograms.dev'

echo "** b2b: Restarting **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` restart b2b
