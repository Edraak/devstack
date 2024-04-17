set -e

echo "** Bring progs up **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` up -d progs

echo "** Creating databases **"
echo "CREATE DATABASE IF NOT EXISTS edraakprograms;" | docker exec -i edx.devstack.mysql8 mysql -uroot mysql


echo "** Progs: Setting correct python version **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec progs bash -c 'update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1'

echo "** Progs: Copy cacheed files to code dir **"
#docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec progs bash -c 'cp -Rn /cache/* /app/.'
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec progs bash -c 'pip3 install -r requirements.txt'

echo "** Progs: Migrating databases **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec progs bash -c 'python3.8 manage.py migrate --settings=edraakprograms.dev'

echo "** Progs: Compiling assets **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec progs bash -c 'npm rebuild node-sass'
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec progs bash -c 'chown -R root ~/.npm'
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec progs bash -c 'rm -rf node_modules/'
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec progs bash -c 'npm install'

docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec progs bash -c 'npm run dev'
docker-compose `echo ${DOCKER_COMPOSE_FILES}` exec progs bash -c 'python manage.py collectstatic --ignore="*.less" --ignore="*.scss" --noinput --clear --settings=edraakprograms.static'

echo "** Progs: Restarting **"
docker-compose `echo ${DOCKER_COMPOSE_FILES}` restart progs
