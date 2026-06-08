#!/usr/bin/env bash
set -e

echo "Provisioning edraak-auth service..."

docker exec -i edx.devstack.mysql mysql -uroot -e "
    CREATE DATABASE IF NOT EXISTS edraak_auth CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    GRANT ALL PRIVILEGES ON edraak_auth.* TO 'root'@'%';
    FLUSH PRIVILEGES;
"

docker exec -i edraak.devstack.edraak_auth bash -c "
    python manage.py migrate --noinput
"

echo "edraak-auth provisioning complete."
