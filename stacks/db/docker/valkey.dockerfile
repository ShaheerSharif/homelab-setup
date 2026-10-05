FROM dhi.io/valkey:9

COPY --chmod=755 stacks/db/scripts/valkey-entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=755 stacks/db/scripts/valkey-healthcheck.sh /usr/local/bin/healthcheck.sh

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
