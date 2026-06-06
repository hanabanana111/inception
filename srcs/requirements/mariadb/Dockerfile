FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
	mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/mariadb_setup.sh /usr/local/bin/mariadb_setup.sh

RUN mkdir -p /run/mysqld \
	&& chown -R mysql:mysql /run/mysqld \
	&& chmod +x /usr/local/bin/mariadb_setup.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb_setup.sh"]
