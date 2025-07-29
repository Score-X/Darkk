FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

# Install required packages
RUN apt update && \
    apt install -y \
    curl git cmake g++ make \
    build-essential libjson-c-dev \
    libwebsockets-dev libssl-dev zlib1g-dev \
    bash && \
    rm -rf /var/lib/apt/lists/*

# Build ttyd
RUN git clone https://github.com/tsl0922/ttyd.git && \
    cd ttyd && mkdir build && cd build && \
    cmake .. && make && make install && \
    cd ../.. && rm -rf ttyd

# Create a basic HTML override for mobile-friendly viewport
RUN mkdir -p /usr/local/share/ttyd/html && \
    echo '<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1"><title>Terminal</title></head><body></body></html>' > /usr/local/share/ttyd/html/index.html

# Expose ttyd port
EXPOSE 7681

# Launch bash login shell with better compatibility and mobile view
CMD ["ttyd", "--index", "/usr/local/share/ttyd/html/index.html", "-p", "7681", "-t", "fontSize=14", "bash", "-l"]
