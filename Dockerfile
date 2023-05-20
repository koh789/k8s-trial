FROM alpine:3.11.3

ARG APP

ENV LANG='ja_JP.UTF-8' \
    LANGUAGE='ja_JP:ja' \
    TZ='Asia/Tokyo' \
    APP_DIR=/var/app 

RUN apk --no-cache add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

COPY bin/${APP} ${APP_DIR}/${APP}

WORKDIR ${APP_DIR}

ENTRYPOINT ["exec", "./${APP}"]
