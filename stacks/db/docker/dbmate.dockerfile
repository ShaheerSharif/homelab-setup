FROM ghcr.io/amacneil/dbmate:2

COPY --chmod=755 stacks/db/scripts/dbmate-entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["migrate"]
