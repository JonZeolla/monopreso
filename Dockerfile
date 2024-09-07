FROM node:22-slim

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

ARG TARGETARCH
RUN if [ "${TARGETARCH}" = "arm64" ]; then \
      apt-get update && \
      apt-get install -y --no-install-recommends chromium; \
    fi

# Install node_modules globally
WORKDIR /
COPY reveal.js/package.json reveal.js/package-lock.json /
# Separate for caching
RUN npm install

# This expects that the monorepo is mounted to /usr/src/app/ at runtime
WORKDIR /usr/src/app/reveal.js
ENTRYPOINT ["npm", "start", "--", "--host", "0.0.0.0"]
