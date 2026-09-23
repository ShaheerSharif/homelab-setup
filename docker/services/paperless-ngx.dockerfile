FROM ghcr.io/paperless-ngx/paperless-ngx:latest

ENV PAPERLESS_TIKA_ENABLED=1
ENV PAPERLESS_TIKA_GOTENBERG_ENDPOINT="http://gotenberg:3000"
ENV PAPERLESS_TIKA_ENDPOINT="http://tika:9998"

# DB Config
ENV PAPERLESS_DBENGINE="postgresql"
ENV PAPERLESS_DBHOST="postgres"
# TODO: pass these credentials securly
ENV PAPERLESS_DBNAME="paperless_db"
ENV PAPERLESS_DBUSER="paperless_user"
ENV PAPERLESS_DBPASS="paperless"
