FROM alpine:3.21.3 AS hugo-install

ENV HUGO_VERSION="0.145.0"

ENV HUGO_AMD64_CHECKSUM="7c7468946da8fa282508e5bf3b8d6e972f3cae41e826d45b4a9aa9a104a74ae4"
ENV HUGO_ARM64_CHECKSUM="ec6543e43efc96dd40aacb578413bb3d0532a3e8898d49edff6528f06333866e"

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
