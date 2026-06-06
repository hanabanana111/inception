#!/bin/bash

set -euo pipefail

WP_PATH="/var/www/html"
SITE_URL="https://${DOMAIN_NAME:?DOMAIN_NAME is not set}"

: "${SQL_DATABASE:?SQL_DATABASE is not set}"
: "${SQL_USER:?SQL_USER is not set}"
: "${SQL_PASSWORD_FILE:?SQL_PASSWORD_FILE is not set}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is not set}"
: "${WP_USER:?WP_USER is not set}"

WP_ADMIN_PASSWORD_FILE="${WP_ADMIN_PASSWORD_FILE:-/run/secrets/wp_admin_password}"
WP_USER_PASSWORD_FILE="${WP_USER_PASSWORD_FILE:-/run/secrets/wp_user_password}"

mkdir -p "$WP_PATH"
cd "$WP_PATH"

# Load credentials from secret files.
DB_PASSWORD="$(cat "$SQL_PASSWORD_FILE")"
WP_ADMIN_PASSWORD="$(cat "$WP_ADMIN_PASSWORD_FILE")"
WP_USER_PASSWORD="$(cat "$WP_USER_PASSWORD_FILE")"

if [ -f "$WP_PATH/wp-config.php" ]; then
	echo "WordPress is already configured. Skipping initialization."
else
	echo "Downloading WordPress core files."
	wp core download --allow-root

	echo "Creating WordPress configuration."
	wp config create --allow-root \
		--dbname="$SQL_DATABASE" \
		--dbuser="$SQL_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="mariadb" \
		--skip-check

	echo "Installing WordPress."
	wp core install --allow-root \
		--url="$SITE_URL" \
		--title="Inception" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="${WP_ADMIN_USER}@${DOMAIN_NAME}" \
		--skip-email

	echo "Creating the regular WordPress user."
	wp user create --allow-root \
		"$WP_USER" \
		"${WP_USER}@${DOMAIN_NAME}" \
		--role=author \
		--user_pass="$WP_USER_PASSWORD"
fi

exec php-fpm7.4 -F
