FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Kolkata

# Install packages and ttyd
RUN apt update && \
    apt install -y curl git wget tzdata build-essential cmake g++ \
    libjson-c-dev libwebsockets-dev libssl-dev zlib1g-dev pkg-config cmake \
    neofetch nano htop && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/tsl0922/ttyd.git && \
    cd ttyd && mkdir build && cd build && \
    cmake .. && make && make install && \
    cd / && rm -rf /ttyd

EXPOSE 7681

# Launch ttyd on port 7681 with mobile-friendly config
CMD ["ttyd", "-p", "7681", "-t", "fontSize=14", "-t", "rendererType=webgl", "bash", "-l"]
