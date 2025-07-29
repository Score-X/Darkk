FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && \
    apt install -y unzip openssh-server curl wget sudo netcat && \
    mkdir /var/run/sshd

# Set root password
RUN echo 'root:Score-x' | chpasswd

# Configure SSH
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

# Expose SSH and fake HTTP port
EXPOSE 22 8080

# Start everything
CMD bash -c "\
  service ssh start && \
  ngrok tcp 22 --region ap > /dev/null & \
  sleep 8 && \
  echo '=========================================' && \
  echo '🔐 Connect using:' && \
  curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'tcp://[^\\\"]*' && \
  echo '=========================================' && \
  while true; do echo 'OK' | nc -l -p 8080; done"
