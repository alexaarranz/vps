#!/usr/bin/env sh
set -e

# Only handle our domain
if [ "$Le_Domain" != "*.myhomeassistant.app" ]; then
  echo "Skipping hook for $Le_Domain"
  exit 0
fi

# Detect key type (ECDSA or RSA) and set CERT_DIR accordingly
if [ -d "/acme.sh/${Le_Domain}_ecc" ]; then
  CERT_DIR="/acme.sh/${Le_Domain}_ecc"   # ECDSA folder
elif [ -d "/acme.sh/${Le_Domain}" ]; then
  CERT_DIR="/acme.sh/${Le_Domain}"       # RSA folder
else
  echo "No cert directory found for $Le_Domain"
  exit 1
fi

cp "${CERT_DIR}/fullchain.cer"   /mosquitto-config/fullchain.pem
cp "$$   {CERT_DIR}/   $${Le_Domain}.key" /mosquitto-config/privkey.pem

# Fix permissions (mosquitto uid/gid is 1883)
chown 1883:1883 /mosquitto-config/fullchain.pem /mosquitto-config/privkey.pem 2>/dev/null || true

# Graceful reload (no client disconnects)
docker exec mqtt-broker kill -HUP 1

echo "[$(date)] Renewed & reloaded MQTT cert for $Le_Domain"
