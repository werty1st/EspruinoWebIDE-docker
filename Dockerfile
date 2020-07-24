FROM ${ARCH}node:lts-buster-slim

LABEL Maintainer="werty1st"

ARG UID=1000
ARG GID=1000

WORKDIR /home/pi/EspruinoWebIDE

# install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends mosquitto-clients \
        bluetooth bluez libcap2-bin \
        git wget make gcc g++ libbluetooth-dev libudev-dev build-essential ca-certificates python && \
    git clone --depth=1 'https://github.com/espruino/EspruinoWebIDE.git' /home/pi/EspruinoWebIDE && \
    yarn install && \
    apt-get remove -y git wget make gcc g++ libbluetooth-dev libudev-dev build-essential ca-certificates python && \    
    rm -rf /var/lib/apt/lists/*

RUN setcap cap_net_raw+eip $(eval readlink -f `which node`)

RUN chown -R ${UID}:${GID} .
USER ${UID}:${GID}

CMD [ "node", "server.js" ]
