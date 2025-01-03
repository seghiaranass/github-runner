FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG DOCKER_GROUP_GID=988 # GID of the host's docker group


# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        tar \
        jq \
        git \
        libicu-dev \
        libkrb5-3 \
        zlib1g \
        libssl-dev \
        docker.io && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Install docker compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.32.1/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
RUN mv /usr/local/bin/docker-compose /usr/bin/docker-compose
RUN chmod +x /usr/bin/docker-compose

# Create docker group with the correct GID and user
RUN groupadd -g ${DOCKER_GROUP_GID} docker || true && \
    useradd --create-home actions && \
    usermod -aG docker actions

USER actions
WORKDIR /actions

# Your existing runner setup
RUN curl -o actions-runner-linux-x64-2.321.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-x64-2.321.0.tar.gz && \
    tar xzf actions-runner-linux-x64-2.321.0.tar.gz && \
    rm -f actions-runner-linux-x64-2.321.0.tar.gz

USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown actions:actions /entrypoint.sh
USER actions

# Create work directory
RUN mkdir -p /actions/_work

ENTRYPOINT ["/entrypoint.sh"]