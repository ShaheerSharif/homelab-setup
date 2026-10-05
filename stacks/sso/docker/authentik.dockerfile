FROM ghcr.io/goauthentik/server:2026.8.3

COPY --chmod=755 stacks/sso/scripts/authentik-healthcheck.sh /usr/local/bin/healthcheck.sh

CMD [ "server" ]

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD [ "/usr/local/bin/healthcheck.sh" ]
