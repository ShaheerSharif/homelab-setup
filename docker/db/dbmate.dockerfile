FROM ghcr.io/amacneil/dbmate:2

COPY --chmod=755 entrypoints/dbmate.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["migrate"]
