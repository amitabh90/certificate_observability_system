FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ca-certificates curl openssl nginx \
    telegraf \
    && rm -rf /var/lib/apt/lists/*

# Config templates
COPY nginx.conf /etc/nginx/nginx.conf
COPY telegraf.conf /etc/telegraf/telegraf.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
    && mkdir -p /etc/nginx/certs /var/www/html

EXPOSE 8443 9273

ENTRYPOINT ["/entrypoint.sh"]
