#!/bin/sh

set -e
CONFIG_PATH=/etc/nutcracker.conf

generate_config() {
    cat > $CONFIG_PATH <<EOF
pool:
  listen: 0.0.0.0:${LISTEN_PORT}
  hash: ${HASH}
  distribution: ${DISTRIBUTION}
  redis: true
  auto_eject_hosts: ${AUTO_EJECT_HOSTS}
  timeout: ${TIMEOUT}
  server_retry_timeout: ${SERVER_RETRY_TIMEOUT}
  server_failure_limit: ${SERVER_FAILURE_LIMIT}
  server_connections: ${SERVER_CONNECTIONS}
  preconnect: ${PRECONNECT}
  servers:
EOF

    IFS=,
    for server in $REDIS_SERVERS; do
      echo "   - ${server}" >> $CONFIG_PATH
    done
}


if [ ! -e "$CONFIG_PATH" ]; then
    generate_config
fi

exec "$@"
