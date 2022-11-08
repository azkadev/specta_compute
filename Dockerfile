FROM ubuntu

WORKDIR /app/

ADD ./ /app/

RUN apt-get update
RUN apt-get upgrade

RUN apt-get install -y \
    sudo \
    wget \
    curl \
    lxc \
    iptables \
    ca-certificates \
    apt-utils \
    neofetch \
    git \
    apt-transport-https \
    software-properties-common \
    nmap

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-cache policy docker-ce
RUN apt-get install -y docker-ce 

# RUN curl -sSL https://get.docker.com/ | sh

# # https://stackoverflow.com/questions/28898787/how-to-handle-specific-hostname-like-h-option-in-dockerfile
# RUN mv /usr/bin/hostname{,.bkp}; \
#     echo "echo myhost.local" > /usr/bin/hostname; \
#     chmod +x /usr/bin/hostname

## dart install
RUN apt-get install apt-transport-https -y
RUN wget -qO /etc/apt/trusted.gpg.d/dart_linux_signing_key.asc https://dl-ssl.google.com/linux/linux_signing_key.pub
RUN wget -qO /etc/apt/sources.list.d/dart_stable.list https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list
RUN apt-get update
RUN apt-get install dart -y

## compile to exe
RUN dart pub get
RUN dart compile exe ./bin/specta_compute.dart -o ./index

CMD ["./index"]