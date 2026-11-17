# Nginx Proxy Manager with a node security overlay: if a newer node patch of the
# same major is out than the one upstream ships, it replaces upstream's binary
# (see node-overlay.sh).
ARG NPM_VERSION
ARG NODE_VERSION
FROM docker.io/library/node:${NODE_VERSION}-trixie-slim AS node

FROM docker.io/jc21/nginx-proxy-manager:${NPM_VERSION}
COPY --from=node /usr/local/bin/node /tmp/node-overlay/node
COPY node-overlay.sh /tmp/node-overlay.sh
RUN sh /tmp/node-overlay.sh && rm -rf /tmp/node-overlay /tmp/node-overlay.sh
