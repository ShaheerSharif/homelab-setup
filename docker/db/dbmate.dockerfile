FROM ghcr.io/amacneil/dbmate:2

ARG POSTGRES_USER='postgres'
ARG POSTGRES_DB='postgres'

ENTRYPOINT ["/bin/sh", "-c", "export DATABASE_URL=\"postgres://${POSTGRES_USER}:$(cat /run/secrets/postgres_password)@postgres:5432/${POSTGRES_DB}?sslmode=disable\"; exec dbmate \"$@\"", "--"]

CMD ["migrate"]
