#! /bin/bash

DOMAIN_ROOT="/var/lib/acme/domains"
ACCOUNT_KEY="/var/lib/acme/account.key"
ACME_DIR="/var/www/challenges"

[ -d "$DOMAIN_ROOT" ] || { echo "ERROR: DOMAIN_ROOT dir does not exists" 1>&2; exit 1; }
[ -f "$ACCOUNT_KEY" ] || { echo "ERROR: ACCOUNT_KEY not found." 1>&2; exit 1; }
[ -d "$ACME_DIR" ] || { echo "ERROR: ACME_DIR dir does not exists" 1>&2; exit 1; }

if [[ ( ! -f "$DOMAIN_ROOT/intermediate.pem" ) || -n $(find "$DOMAIN_ROOT/intermediate.pem" -mtime +30 -print) ]]; then
    wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > "$DOMAIN_ROOT/intermediate.pem"
fi

sed -E 's/#.*$//; s/^\s+//; s/\s+$//' /usr/local/etc/lets-encrypt-hosts | grep -v '^$' | while read DOMAIN; do
    if [[ ( ! -f "$DOMAIN_ROOT/$DOMAIN.pem" ) || -n $(find "$DOMAIN_ROOT/intermediate.pem" -mtime +60 -print) ]]; then
        if [[ ! -f "$DOMAIN_ROOT/$DOMAIN.key" ]]; then
            echo "INFO: Generation private key for $DOMAIN";
            openssl genrsa 4096 > "$DOMAIN_ROOT/$DOMAIN.key"
            openssl req -new -sha256 -key "$DOMAIN_ROOT/$DOMAIN.key" -subj "/CN=$DOMAIN" > "$DOMAIN_ROOT/$DOMAIN.csr"
        fi

        echo "INFO: Generation cert for $DOMAIN";
        acme-tiny --account-key "$ACCOUNT_KEY" --csr "$DOMAIN_ROOT/$DOMAIN.csr" --acme-dir "$ACME_DIR" > "$DOMAIN_ROOT/$DOMAIN.crt" || exit $?
        cat "$DOMAIN_ROOT/$DOMAIN.crt" "$DOMAIN_ROOT/intermediate.pem" > "$DOMAIN_ROOT/$DOMAIN.pem"
    else
        echo "INFO: skip $DOMAIN"
    fi
    (
        echo "ssl_certificate /var/lib/acme/domains/$DOMAIN.pem;"
        echo "ssl_certificate_key /var/lib/acme/domains/$DOMAIN.key;"
    ) > "$DOMAIN_ROOT/$DOMAIN-nginx-keys.conf"
done
