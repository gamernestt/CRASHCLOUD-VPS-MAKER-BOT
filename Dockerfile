FROM ubuntu:24.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update & install packages
RUN apt-get update && apt-get install -y \
    tmate \
    openssh-server \
    openssh-client \
    systemd \
    systemd-sysv \
    dbus \
    dbus-user-session \
    curl \
    ufw \
    net-tools \
    iproute2 \
    hostname \
    && rm -rf /var/lib/apt/lists/*

# Allow root SSH login
RUN sed -i 's/^#\?\s*PermitRootLogin\s\+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'root:root' | chpasswd

# Prevent services from trying to start during build
RUN printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# Auto-start systemd-logind
RUN echo "systemctl start systemd-logind" >> /etc/profile

# Configure UFW
RUN ufw allow 80 && ufw allow 443

# Default command
CMD ["bash"]

# Entry point: systemd
STOPSIGNAL SIGRTMIN+3
ENTRYPOINT ["/sbin/init"]
