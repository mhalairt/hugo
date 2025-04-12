FROM alpine:3.21.3 AS hugo-install

ENV HUGO_VERSION="0.146.2"

ENV HUGO_AMD64_CHECKSUM="1ed22c5b382afbb97f3115e73aad1f45377b909a84160b0b57ec680c67a48ceb"
ENV HUGO_ARM64_CHECKSUM="ab98c392ada1611a8e0449db424598d0445638be134371a3c1af744a33cae43f"

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
