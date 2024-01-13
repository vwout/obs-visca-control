FROM alpine:3.19

ARG LUA_VERSION=5.2
ARG LUA_MODULES="lunit luacheck luacov luacov-html"

RUN apk add --no-cache \
        bash \
        luajit \
        lua${LUA_VERSION} \
        lua${LUA_VERSION}-bit32 \
        lua${LUA_VERSION}-filesystem \
        lua${LUA_VERSION}-socket \
    \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        openssl-dev \
        lua${LUA_VERSION}-dev \
        luarocks${LUA_VERSION} \
    \
    && ln -s /usr/bin/lua${LUA_VERSION} /usr/local/bin/lua \
    \
    && for rock in ${LUA_MODULES}; do \
        luarocks-${LUA_VERSION} install ${rock}; \
       done \
    \
    && apk del .build-deps

ADD https://github.com/philips/lualint/raw/master/lualint /bin/lualint
RUN chmod +x /bin/lualint \
    && \
    ln -s /usr/bin/luac${LUA_VERSION} /usr/bin/luac

RUN mkdir -p /github/workspace
VOLUME ["/github/workspace"]

WORKDIR "/github/workspace"
