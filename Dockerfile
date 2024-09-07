FROM node:22-slim

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

ARG TARGETARCH
# hadolint:ignore=DL3008
RUN if [ "${TARGETARCH}" = "arm64" ]; then \
      apt-get update \
   && apt-get install -y --no-install-recommends chromium \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*; \
    fi

# Install node_modules globally
WORKDIR /
COPY reveal.js/package.json reveal.js/package-lock.json /
# Separate for caching
RUN npm install

# This expects that the monorepo is mounted to /usr/src/app/ at runtime
WORKDIR /usr/src/app/reveal.js
ENTRYPOINT ["npm", "start", "--", "--host", "0.0.0.0"]

# These align with https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.title="Monopreso"
LABEL org.opencontainers.image.description="Jon Zeolla's monorepo of presentations"
LABEL org.opencontainers.image.url="https://jonzeolla.com"
LABEL org.opencontainers.image.source="https://github.com/jonzeolla/monopreso"
