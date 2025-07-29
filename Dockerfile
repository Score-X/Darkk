FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

# Install dependencies
RUN apt update && \
    apt install -y git cmake g++ make \
    build-essential libjson-c-dev \
    libwebsockets-dev libssl-dev zlib1g-dev \
    bash curl sudo && \
    rm -rf /var/lib/apt/lists/*

# Build ttyd from source
RUN git clone https://github.com/tsl0922/ttyd.git && \
    cd ttyd && mkdir build && cd build && \
    cmake .. && make && make install && \
    cd ../.. && rm -rf ttyd

# Expose ttyd's default port
EXPOSE 7681

# Run ttyd with bash login shell
CMD ["ttyd", "-p", "7681", "-t", "fontSize=14", "-t", "rendererType=webgl", "bash", "-l"]
