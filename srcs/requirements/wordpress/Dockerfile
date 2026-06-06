FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
	php-fpm \
	php-cli \
	php-mysql \
	wget \
	curl \
	ca-certificates \
	mariadb-client \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	-o /usr/local/bin/wp \
	&& chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/wp_setup.sh /usr/local/bin/wp_setup.sh

RUN mkdir -p /run/php /var/www/html \
	&& chown -R www-data:www-data /var/www/html \
	&& chmod +x /usr/local/bin/wp_setup.sh

EXPOSE 9000

ENTRYPOINT ["wp_setup.sh"]
