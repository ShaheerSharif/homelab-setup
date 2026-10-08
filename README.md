# Homelab Setup

This is a homelab setup deployed as stacks to ensure modularity with shared dependencies among them.

## Configuration

Copy `.env.example` to `.env`. These values are **required**. Without these the compose files won't execute.

```
DOMAIN=your-site.com
POSTGRES_PASSWORD=my-secret-password
VALKEY_PASSWORD=myLargeAlphaNumericPassword
PAPERLESS_SECRET_KEY=my-secret-key
AUTHENTIK_SECRET_KEY=my-secret-key
```

## Usage

- Start the containers

```sh
$ chmod u+x ./start.sh
$ ./start.sh
```

- Stop the containers

```sh
$ chmod u+x ./stop.sh
$ ./stop.sh

# Stop containers and delete volumes
$ ./stop.sh -v

# Stop containers and delete volumes without asking for confirmation
$ ./stop.sh -v -y
```

## Stacks

This contains a list of all the stacks used and their dependencies.

| Service name       | Stack name               | Image                                          | Depends on service                                   |
| ------------------ | ------------------------ | ---------------------------------------------- | ---------------------------------------------------- |
| `postgres`         | `db`                     | `dhi.io/postgres:18-alpine3.23`                |                                                      |
| `valkey`           | `db`                     | `dhi.io/valkey:9`                              |                                                      |
| `migrate`          | `db`                     | `ghcr.io/amacneil/dbmate:2`                    | `postgres`                                           |
| `socket-proxy`     | `socket-proxy`           | `ghcr.io/tecnativa/docker-socket-proxy:v0.5.0` |                                                      |
| `gotenberg`        | `utils`                  | `docker.io/gotenberg/gotenberg:8.37`           |                                                      |
| `tika`             | `utils`                  | `docker.io/apache/tika:3.3.1.0`                |                                                      |
| `authentik-worker` | `sso`                    | `ghcr.io/goauthentik/server:2026.8.3`          | `postgres`, `migrate`, `socket-proxy`                |
| `authentik`        | `sso`                    | `ghcr.io/goauthentik/server:2026.8.3`          | `postgres`, `migrate`                                |
| `paperless`        | `services/paperless-ngx` | `ghcr.io/paperless-ngx/paperless-ngx:latest`   | `postgres`, `migrate`, `valkey`, `tika`, `gotenberg` |
| `traefik`          | `server`                 | `dhi.io/traefik:3-debian-dev`                  | `socket-proxy`                                       |
