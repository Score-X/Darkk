# Use official prebuilt ttyd image
FROM tsl0922/ttyd:latest

# Install optional tools inside the container
RUN apt update && \
    apt install -y neofetch curl nano git && \
    rm -rf /var/lib/apt/lists/*

# Expose the port ttyd will run on
EXPOSE 7681

# Run ttyd on port 7681 with mobile-friendly settings
CMD ["ttyd", "-p", "7681", "-t", "fontSize=14", "-t", "rendererType=webgl", "bash", "-l"]
