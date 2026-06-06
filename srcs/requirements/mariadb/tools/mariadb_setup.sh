#!/bin/bash

set -eu

: "${SQL_PASSWORD_FILE:?SQL_PASSWORD_FILE is not set}"
: "${SQL_ROOT_PASSWORD_FILE:?SQL_ROOT_PASSWORD_FILE is not set}"
: "${SQL_DATABASE:?SQL_DATABASE is not set}"
: "${SQL_USER:?SQL_USER is not set}"

if [ -d "/var/lib/mysql/${SQL_DATABASE}" ]; then
	exec mysqld --user=mysql
fi

DB_PASSWORD="$(cat "$SQL_PASSWORD_FILE")"
DB_ROOT_PASSWORD="$(cat "$SQL_ROOT_PASSWORD_FILE")"

if [ ! -d /var/lib/mysql/mysql ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

cat > /tmp/init.sql <<EOF
CREATE DATABASE IF NOT EXISTS ${SQL_DATABASE};
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${SQL_DATABASE}.* TO '${SQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock --pid-file=/tmp/mariadb-init.pid &
MYSQLD_PID="$!"

until mariadb --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot -e "SELECT 1;" >/dev/null 2>&1; do
	sleep 1
done

mariadb --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot < /tmp/init.sql

kill "$MYSQLD_PID"
wait "$MYSQLD_PID" || true

rm -f /tmp/init.sql

exec mysqld --user=mysql
