FROM alpine:3.21.3 AS hugo-install

ENV HUGO_VERSION="0.144.2"

ENV HUGO_AMD64_CHECKSUM="961b258ba2478bec4b2756be4f8982b221bf2d6c1b20f0727ad86e84677053d9"
ENV HUGO_ARM64_CHECKSUM="5d0756c3e72a7386f3a3fcd432789c39c3d1239715e147c63bd7a73bbfcfc93f"

RUN set -eux \
    && mkdir -p /usr/opt/hugo \
    && apk update \
    && apk add --no-cache \
        gzip \
        tar \
    && cd /usr/opt/hugo \
    && HUGO_ARCH=$(apk --print-arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) \
    && wget -O hugo.tar.gz "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-${HUGO_ARCH}.tar.gz" \
    && HUGO_CHECKSUM=$(echo "$HUGO_ARCH" | sed s/arm64/${HUGO_ARM64_CHECKSUM}/ | sed s/amd64/${HUGO_AMD64_CHECKSUM}/) \
    && echo "${HUGO_CHECKSUM} *hugo.tar.gz" | sha256sum -c - \
	&& tar -xzf hugo.tar.gz \
	&& rm hugo.tar.gz \
    && rm -rf /var/cache/apk/*


FROM alpine:3.21.3

COPY --from=hugo-install /usr/opt/hugo/hugo /usr/local/bin/hugo

RUN set -eux \
    && chmod a+x /usr/local/bin/hugo \
    && apk update \
    && apk add --no-cache \
        libc6-compat \
        libgcc \
        libstdc++ \
    && rm -rf /var/cache/apk/*

VOLUME /usr/data

WORKDIR /usr/data

CMD [ "/usr/local/bin/hugo" ]
