FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && \
    apt install -y unzip openssh-server curl wget sudo && \
    mkdir /var/run/sshd

# Set root password
RUN echo 'root:Score-x' | chpasswd

# Configure SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'PermitEmptyPasswords no' >> /etc/ssh/sshd_config

# Install Ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip && \
    unzip ngrok.zip && \
    mv ngrok /usr/local/bin && \
    chmod +x /usr/local/bin/ngrok && \
    rm ngrok.zip

# Set Ngrok authtoken
RUN ngrok config add-authtoken 2xWnfOyRd1Zi5KaeMnvqsIziHLW_6PYhXB2qC9AKg6grTubJJ

# Expose SSH port
EXPOSE 22

# Launch SSH and Ngrok
CMD bash -c "\
  service ssh start && \
  nohup ngrok tcp 22 --region ap &>/dev/null & \
  sleep 10 && \
  echo '🔐 SSH link:' && \
  curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'tcp://[^\\\"]*' && \
  tail -f /dev/null"
