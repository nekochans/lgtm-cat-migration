FROM migrate/migrate:v4.14.1

WORKDIR /opt/app

COPY ../migrations ./migrations
COPY ../Makefile ./
COPY ../migrate_up.sh ./
COPY ../migrate_down.sh ./

RUN set -eux && \
  apk update && \
  apk add --no-cache make

ENTRYPOINT []
