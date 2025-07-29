FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system packages
RUN apt update && \
    apt install -y \
        curl git cmake g++ make \
        build-essential libjson-c-dev \
        libwebsockets-dev libssl-dev zlib1g-dev \
        bash && \
    rm -rf /var/lib/apt/lists/*

# Clone and build ttyd
RUN git clone https://github.com/tsl0922/ttyd.git && \
    cd ttyd && mkdir build && cd build && \
    cmake .. && make && make install && \
    cd ../.. && rm -rf ttyd

# Expose the ttyd port
EXPOSE 7681

# Run ttyd on port 7681 with bash
CMD ["ttyd", "-p", "7681", "bash"]
