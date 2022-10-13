FROM ubuntu

WORKDIR /app/

ADD ./ /app/

RUN apt-get update

RUN apt-get install -y \
    sudo \
    wget \
    curl \
    lxc \
    iptables \
    ca-certificates \
    apt-utils

RUN curl -sSL https://get.docker.com/ | sh

## dart install
RUN apt-get install apt-transport-https -y
RUN wget -qO /etc/apt/trusted.gpg.d/dart_linux_signing_key.asc https://dl-ssl.google.com/linux/linux_signing_key.pub
RUN wget -qO /etc/apt/sources.list.d/dart_stable.list https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list
RUN apt-get update
RUN apt-get install dart -y


## compile to exe
RUN dart pub get
RUN dart compile exe ./bin/specta_paas.dart -o ./index

CMD ["./index"]