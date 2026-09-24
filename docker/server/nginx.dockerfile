FROM dhi.io/nginx:1

ARG NGINX_HOST

ENV NGINX_HOST=${NGINX_HOST}
ENV NGINX_PORT=80

COPY config/nginx/conf.d    /etc/nginx/conf.d
COPY config/nginx/snippets  /etc/nginx/snippets
COPY config/nginx/certs     /etc/nginx/certs
COPY config/nginx/vhost.d   /etc/nginx/vhost.d
COPY config/nginx/htpasswd  /etc/nginx/htpasswd
COPY html                   /usr/share/nginx/html

EXPOSE 80
EXPOSE 443
