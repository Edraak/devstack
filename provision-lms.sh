set -e
set -o pipefail
set -x

apps=( lms )

echo "** Edx **"
echo -e "${GREEN}Creating databases and users...${NC}"
docker exec -i edx.devstack.mysql mysql -uroot mysql < provision.sql
docker exec -i edx.devstack.mongo mongosh < mongo-provision.js

# Load database dumps for the largest databases to save time
./load-db.sh edxapp
./load-db.sh edxapp_csmh

# Bring edxapp containers online
for app in "${apps[@]}"; do
    echo ${DOCKER_COMPOSE_FILES}
    docker compose `echo ${DOCKER_COMPOSE_FILES}` up -d $app
done


echo ${DOCKER_COMPOSE_FILES}
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && NO_PYTHON_UNINSTALL=1 NO_PREREQ_INSTALL=0 paver install_prereqs'

docker cp ./mysql8_edx_fix/add_replace_sensitive_column.sql edx.devstack.mysql:/add_replace_sensitive_column.sql
docker compose exec mysql bash -c "mysql -u root edxapp < /add_replace_sensitive_column.sql"
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec lms bash -c  'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && python manage.py lms migrate enterprise 0042 --fake --settings=devstack_docker'
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && python manage.py lms migrate enterprise 0046 --fake --settings=devstack_docker'

docker cp ./mysql8_edx_fix/add_verify_student_constraint.sql edx.devstack.mysql:/add_verify_student_constraint.sql
docker compose exec mysql bash -c "mysql -u root edxapp < /add_verify_student_constraint.sql"
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && python manage.py lms migrate verify_student 0006 --fake --settings=devstack_docker'



# Run edxapp migrations first since they are needed for the service users and OAuth clients
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && paver update_db --settings devstack_docker'

# Create a superuser for edxapp
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec lms bash -c 'source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py lms --settings=devstack_docker manage_user edx edx@example.com --superuser --staff'
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec lms bash -c 'source /edx/app/edxapp/edxapp_env && echo "from django.contrib.auth import get_user_model; User = get_user_model(); user = User.objects.get(username=\"edx\"); user.set_password(\"edx\"); user.save()" | python /edx/app/edxapp/edx-platform/manage.py lms shell  --settings=devstack_docker'

# Create an enterprise service user for edxapp
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec lms bash -c 'source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py lms --settings=devstack_docker manage_user enterprise_worker enterprise_worker@example.com'

# Enable the LMS-E-Commerce integration
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec lms bash -c 'source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py lms --settings=devstack_docker configure_commerce'

# Create demo course and users
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec lms bash -c '/edx/app/edx_ansible/venvs/edx_ansible/bin/ansible-playbook /edx/app/edx_ansible/edx_ansible/playbooks/demo.yml -v -c local -i "127.0.0.1," --extra-vars="COMMON_EDXAPP_SETTINGS=devstack_docker"'

# Fix missing vendor file by clearing the cache
docker compose `echo ${DOCKER_COMPOSE_FILES}` exec lms bash -c 'rm /edx/app/edxapp/edx-platform/.prereqs_cache/Node_prereqs.sha1'

# Create static assets for both LMS and Studio
for app in "${apps[@]}"; do
    docker compose `echo ${DOCKER_COMPOSE_FILES}` exec $app bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && paver update_assets --settings devstack_docker'
done

# Provision a retirement service account user
./provision-retirement-user.sh retirement retirement_service_worker

# Add demo program
./programs/provision.sh lms
