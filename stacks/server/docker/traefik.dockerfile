FROM dhi.io/traefik:3-debian-dev

HEALTHCHECK --interval=10s \
    --timeout=5s \
    --retries=5 \
    CMD [ "traefik", "healthcheck", "--ping" ]
