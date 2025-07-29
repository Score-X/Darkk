FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt update && \
    apt install -y unzip openssh-server curl wget sudo netcat && \
    mkdir /var/run/sshd

# Set root password
RUN echo 'root:Score-x' | chpasswd

# Enable root SSH login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'PermitEmptyPasswords no' >> /etc/ssh/sshd_config

# Install ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip && \
    unzip ngrok.zip && \
    mv ngrok /usr/local/bin/ngrok && \
    chmod +x /usr/local/bin/ngrok && \
    rm ngrok.zip

# Set your ngrok authtoken
RUN ngrok config add-authtoken 2xWnfOyRd1Zi5KaeMnvqsIziHLW_6PYhXB2qC9AKg6grTubJJ

# Expose Render-detectable port
EXPOSE 8080

# Start SSH, Ngrok, dummy HTTP server, and keep alive
CMD bash -c "\
  service ssh start && \
  ngrok tcp 22 --region ap > /dev/null & \
  sleep 10 && \
  echo '🔐 SSH address:' && \
  curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'tcp://[^\\\"]*' && \
  while true; do echo -e 'HTTP/1.1 200 OK\n\nRender alive' | nc -l -p 8080; done"
