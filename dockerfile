FROM jenkins/jenkins:lts-jdk17
USER root

# 1. Set Timezone
ENV TZ=Asia/Calcutta

# 2. Install base packages (Removed libpq-dev, gpg, flake8)
RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    python3 \
    unzip \
    python3-dev \
    jq \
    vim \
    python3-pip \
    ca-certificates \
    curl \
    awscli \
    ffmpeg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# 3. Setup Docker Repo
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list

# 4. Install Docker Components Only
RUN apt-get update && apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# 5. Fix Python environment restriction (Debian 12+ behavior)
RUN rm -f /usr/lib/python3.11/EXTERNALLY-MANAGED

# 6. Add jenkins user to docker group (Optional but recommended for socket access)
# Note: The group ID may need to match your host's docker group ID
RUN usermod -aG docker jenkins

USER jenkins