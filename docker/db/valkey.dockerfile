FROM dhi.io/valkey:9

COPY config/valkey/valkey.conf /etc/valkey/valkey.conf

CMD ["valkey-server", "/etc/valkey/valkey.conf"]
