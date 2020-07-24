# Motivation

I wanted to have a faster way to get EspruinoHub and EspruinoWebIDE running on my Raspberries.

There are two repositories and therefore also two docker images.
One for the Hub and one for the IDE.

It would have been easy to put them all in one but I didn't want to include extra code to make it configurable if one wants to use both or only one of the included programs.

## Preconditions

Install Docker on a RPI:
```bash
sudo -s

curl -sSL https://get.docker.com | sh
apt --fix-broken install
usermod -aG docker pi
apt-get install -y python python3-pip python3-dev libffi-dev libssl-dev
pip3 install docker-compose
```

Install Docker on Ubuntu:
```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io && \
sudo groupadd docker

sudo usermod -aG docker ubuntu && \
sudo systemctl enable docker && \
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
sudo chmod +x /usr/local/bin/docker-compose
```

## Run the image

The images can run alone or togeher if 2 bluetooth devices are present.
One images needs to set the environment variable __BLENO_HCI_DEVICE_ID__ to __0__ and the other to __1__.

### Docker

```bash
docker run -it --rm \
    -e BLENO_HCI_DEVICE_ID=0 \
    --privileged \
    --network=host \
    --volume=/dev:/dev \
    werty1st/espruinowebide:latest
```

### docker-compose.yml

```yml
version: "3.7"

services:
  ide:
    image: werty1st/espruinowebide:latest
    restart: always
    privileged: true
    environment:
      - BLENO_HCI_DEVICE_ID=0
    volumes:
      - /dev:/dev
    network_mode: host
```

```bash
docker-compose up
```

### combined docker-compose.yml

```yml
version: "3.7"

services:
  hub:
    image: werty1st/espruinohub:latest
    restart: always
    privileged: true
    environment:
      - BLENO_ADVERTISING_INTERVAL=300
      - NOBLE_MULTI_ROLE=1
      - BLENO_HCI_DEVICE_ID=0
    volumes:
      - /dev:/dev
    network_mode: host

  ide:
    image: werty1st/espruinowebide:latest
    restart: always
    privileged: true
    environment:
      - BLENO_HCI_DEVICE_ID=1
    volumes:
      - /dev:/dev
    network_mode: host

  mqtt:
    restart: always
    image: eclipse-mosquitto
    ports:
      - 1883:1883

```

```bash
docker-compose up
```

By default the IDE will be available on 

* <http://raspberrypi:8080>
* <http://127.0.0.1:8080>

and the Hub at 

* <http://raspberrypi:1888> 
* <http://127.0.0.1:1888>


Its possible to pass your own config.json into the container:

```yml
version: "3.7"

services:
  hub:
    image: werty1st/espruinohub:latest
    restart: always
    privileged: true
    environment:
      - BLENO_ADVERTISING_INTERVAL=300
      - NOBLE_MULTI_ROLE=1
      - BLENO_HCI_DEVICE_ID=0
    volumes:
      - /dev:/dev
      - config.json:/home/pi/EspruinoHub/config.json
    network_mode: host
```
```bash
docker-compose up
```

## About

The image is a multi arch image to have more portable code (yml files).

It's build for __linux/amd64__, __linux/arm/v7__ and __linux/arm64__. So it should run on Raspbery Pi 2,3,4 and also Intel/AMD x64 Linux systems.

## Security

For me this docker configuration was the most stable so far. It may be possible to restrict access more but its not one of my priorities.

## PRs welcome

## Disclaimer

Im only responsible for the code on this repository.

All credit regarding Espruino goes to Gordon and his contributors.
<https://github.com/espruino/EspruinoWebIDE> and <https://github.com/espruino/EspruinoHub>
