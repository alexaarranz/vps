#!/bin/sh
set -e

# Only handle our domain
if [ "$Le_Domain" != "*.myhomeassistant.app" ]; then
  exit 0
fi

CERT_DIR="/acme.sh/${Le_Domain}_ecc"

cp "${CERT_DIR}/fullchain.cer"   /mosquitto-config/fullchain.pem
cp "$$   {CERT_DIR}/   $${Le_Domain}.key" /mosquitto-config/privkey.pem

# Fix permissions (mosquitto uid/gid is usually 1883)
chown 1883:1883 /mosquitto-config/fullchain.pem /mosquitto-config/privkey.pem 2>/dev/null || true

# Graceful reload (no client disconnects)
docker exec mqtt-broker kill -HUP 1

echo "[$(date)] Renewed & reloaded MQTT cert for $Le_Domain"
