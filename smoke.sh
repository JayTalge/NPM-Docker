#!/bin/bash
# Smoke test: usage smoke.sh <image> <NPM version> <overlay node version>
set -euo pipefail
IMG=$1 VERSION=$2 NODE=$3

# NPM refuses to start without /data and /etc/letsencrypt mounted
docker run -d --name smoke -p 8080:80 -p 8181:81 -v npm-smoke-data:/data -v npm-smoke-le:/etc/letsencrypt "$IMG"
trap 'docker logs --tail 50 smoke; docker rm -f smoke >/dev/null; docker volume rm -f npm-smoke-data npm-smoke-le >/dev/null' EXIT

for i in $(seq 1 90); do
  status=$(curl -fsS http://127.0.0.1:8181/api/ 2>/dev/null | jq -r .status 2>/dev/null || true)
  [ "$status" = "OK" ] && break
  [ "$i" = 90 ] && { echo "NPM API did not come up"; exit 1; }
  sleep 2
done
echo "api ok"
curl -sS -o /dev/null -w "nginx :80 %{http_code}\n" http://127.0.0.1:8080/

got=$(docker exec smoke node -p 'require("/app/package.json").version')
[ "$got" = "$VERSION" ] || { echo "NPM version $got != $VERSION"; exit 1; }

docker exec smoke cat /etc/node-overlay
node=$(docker exec smoke node -v)
[ "$(printf '%s\n%s\n' "v$NODE" "$node" | sort -V | head -1)" = "v$NODE" ] || { echo "node $node older than v$NODE"; exit 1; }
echo "NPM $got, node $node"
