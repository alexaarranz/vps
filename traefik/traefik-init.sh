#!/bin/sh
set -e

# Adds the static route to the WireGuard client subnet via wg-easy's IP on vpn-client-net
# Adjusts 100.64.0.0/16 (WG subnet) and 192.0.2.18 (Traefik's IP address in vpn-client-net) if the WG subnet or traefik's IP on vpn-client-net differs
ip route add 100.64.0.0/16 via 192.0.2.18 || true   # || true = don't fail container if route already exists

echo "Custom route added: $(ip route show 100.64.0.0/16)"

# Now hand over to the original Traefik entrypoint, passing all original arguments
exec /entrypoint.sh "$@"

# Make this script executable (chmod +x traefik-init.sh)
