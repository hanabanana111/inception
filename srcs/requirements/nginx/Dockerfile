FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
	nginx \
	openssl \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl /etc/nginx/conf.d

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf
COPY tools/nginx_setup.sh /usr/local/bin/nginx_setup.sh

RUN chmod +x /usr/local/bin/nginx_setup.sh

EXPOSE 443

CMD ["/usr/local/bin/nginx_setup.sh"]
