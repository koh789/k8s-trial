FROM alpine:3.17

ARG APP

ENV LANG='ja_JP.UTF-8' \
    LANGUAGE='ja_JP:ja' \
    TZ='Asia/Tokyo' \
    ENTRYKIT_VERSION=0.4.0 \
    APP_DIR=/var/app  \
    TARGET_APP=${APP}

RUN apk --no-cache add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

COPY bin/${APP} ${APP_DIR}/${TARGET_APP}

WORKDIR ${APP_DIR}

ENTRYPOINT ["/bin/sh","-c", "${APP_DIR}/${TARGET_APP}"]