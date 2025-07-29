FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install ttyd dependencies
RUN apt update && apt install -y \
    wget curl git cmake g++ make \
    bash build-essential cmake libjson-c-dev \
    libwebsockets-dev libssl-dev zlib1g-dev

# Build and install ttyd
RUN git clone https://github.com/tsl0922/ttyd.git && \
    cd ttyd && mkdir build && cd build && \
    cmake .. && make && make install && \
    cd ../.. && rm -rf ttyd

# Expose the ttyd web port
EXPOSE 7681

# Start ttyd with bash
CMD ["ttyd", "-p", "7681", "bash"]
