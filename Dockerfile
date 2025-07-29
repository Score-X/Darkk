FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install desktop, tools, SSH
RUN apt update -y && apt install --no-install-recommends -y \
  xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
  openssh-server sudo xterm init systemd snapd vim net-tools \
  curl wget git tzdata dbus-x11 x11-utils x11-xserver-utils x11-apps unzip

# Install Firefox
RUN apt install software-properties-common -y && \
  add-apt-repository ppa:mozillateam/ppa -y && \
  echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox && \
  echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
  echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
  echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox && \
  apt update -y && apt install -y firefox xubuntu-icon-theme

# Set root password
RUN echo 'root:Score-x' | chpasswd && \
  mkdir /var/run/sshd && \
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Install Ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip && \
    unzip ngrok.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/ngrok

# Default env for Ngrok token (you can override)
ENV NGROK_AUTHTOKEN="PASTE_YOUR_TOKEN_HERE"

# Expose GUI + SSH
EXPOSE 22 5901 6080

# Create dummy Xauthority
RUN touch /root/.Xauthority

# Start everything
CMD bash -c "\
  echo 'Starting SSH server...' && \
  service ssh start && \
  echo 'Starting VNC server...' && \
  vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && \
  echo 'Starting noVNC server...' && \
  openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
  websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
  echo 'Starting Ngrok tunnel for SSH...' && \
  ngrok config add-authtoken $NGROK_AUTHTOKEN && \
  ngrok tcp 22 > /dev/null & \
  sleep 10 && curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'tcp://[^"]*' && \
  echo 'Everything is running ✅' && \
  tail -f /dev/null"
