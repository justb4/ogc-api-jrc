#!/bin/bash
# Sets global env vars based on host-name
# Needed for various host-dependent configs, especiallly Traefik SSL-certs.

# Export and Defaults

# Assume a local deployment
export DEPLOY_ENV="local"
export TRAEFIK_DOMAIN="localhost"
export TRAEFIK_SSL_ENDPOINT=
export TRAEFIK_SSL_DOMAIN="jrc.map5.nl"
export TRAEFIK_SSL_CERT_RESOLVER=
export TRAEFIK_USE_TLS="false"
export HOST_UID=$(id -u)
export HOST_GID=$(id -g)
export HOST_UID_GID="${HOST_UID}:${HOST_GID}"

# Set host-dependent vars
case "${HOSTNAME}" in
    "OGCAPIJRC")
        DEPLOY_ENV="prod"
        ;;
    "jrc.map5.nl")
        DEPLOY_ENV="prod"
        ;;
    *)
        echo "Default Local Host ${HOSTNAME}"
esac

if [[ ${DEPLOY_ENV} = "prod" ]]
then
	source /etc/environment
    TRAEFIK_SSL_ENDPOINT="https"
    TRAEFIK_SSL_CERT_RESOLVER="le"
    TRAEFIK_USE_TLS="true"
    TRAEFIK_DOMAIN="${TRAEFIK_SSL_DOMAIN}"
fi
