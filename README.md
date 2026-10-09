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

## Limiting Resource Consumption

Below is a list for each of the valid values that can be assigned in the .env file to limit resource consumption.

### Paperless

- `PAPERLESS_OCR_MODE`
  - `auto` _(default)_: detects whether a document already has embedded text via pdftotext. If sufficient text is found, OCR is skipped for that document (--skip-text). If no text is present, OCR runs normally. This is the safest option for mixed document collections.
  - `redo`: Re-OCR everything, replacing any existing text layer. It fails on files with signatures, and it’s slower.
  - `force`: Rasterize every page and OCR it, discarding existing text. It’s the heaviest option.
  - `skip_noarchive`: like `skip`, but doesn’t create an archived PDF/A copy when the original already has text. It saves disk space and processing. Newer releases may rename or add modes, so check the docs for your version.
- `PAPERLESS_OCR_CLEAN`
  - `clean` _(default)_: Runs unpaper to clean pages before OCR, but the cleaned pages aren’t kept in the output.
  - `clean-final`: Same, but the cleaned pages are kept in the archived document.
  - `none`: Skips unpaper entirely. This is the lightest option and is fine for good-quality scans.
- `PAPERLESS_ENABLE_NLTK`: `true` _(default)_ or `false`. NLTK is used for stemming and stop words in the auto-matching classifier. Setting it to false saves a bit of memory and startup time but makes automatic tagging and correspondent matching less accurate, so keep it on if you rely on that.
