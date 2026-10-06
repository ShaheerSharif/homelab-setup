FROM ghcr.io/paperless-ngx/paperless-ngx:latest

COPY --chmod=755 scripts/paperless-ngx-healthcheck.sh /usr/local/bin/healthcheck.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD [ "/usr/local/bin/healthcheck.sh" ]
