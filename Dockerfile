FROM alpine:3.21.3 AS hugo-install

ENV HUGO_VERSION="0.146.5"

ENV HUGO_AMD64_CHECKSUM="eb89d48b2eb4645b8fe1c80b01845504eaa8f074a38122fc8b860edfa71d15f1"
ENV HUGO_ARM64_CHECKSUM="8318167ced2f2a40338a960372865f6f167f2d6d5a37abc68b804d0de78b4404"

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
