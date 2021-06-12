FROM ${ARCH}node:lts-buster-slim

ARG UID=1000
ARG GID=1000

ARG BUILD_DATE
ARG VCS_REF

LABEL Maintainer="https://github.com/werty1st"

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/werty1st/EspruinoWebIDE-docker.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1"

WORKDIR /home/pi/EspruinoWebIDE

# install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bluetooth bluez libcap2-bin \
        git wget make gcc g++ libbluetooth-dev libudev-dev build-essential ca-certificates python && \
    git clone --depth=1 --recursive 'https://github.com/espruino/EspruinoWebIDE.git' /home/pi/EspruinoWebIDE && \
    yarn install && \
    apt-get remove -y git wget make gcc g++ libbluetooth-dev libudev-dev build-essential ca-certificates python && \    
    rm -rf /var/lib/apt/lists/*

RUN setcap cap_net_raw+eip $(eval readlink -f `which node`)

RUN chown -R ${UID}:${GID} .
USER ${UID}:${GID}

CMD [ "node", "server.js" ]

