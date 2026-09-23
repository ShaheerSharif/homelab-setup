FROM dhi.io/valkey:9

COPY config/valkey/valkey.conf /usr/local/valkey/valkey.conf
COPY --chmod=755 scripts/entrypoints/valkey.sh /usr/local/bin/entrypoint.sh
COPY --chmod=755 scripts/healthchecks/valkey-healthcheck.sh /usr/local/bin/healthcheck.sh

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
