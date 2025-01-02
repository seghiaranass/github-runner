FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# Set the GitHub Actions runner version you want.
# Check https://github.com/actions/runner/releases for the latest version.
ENV RUNNER_VERSION="2.321.0"
ENV RUNNER_ARCH="x64"
ENV RUNNER_HOME="/home/actions"
ENV RUNNER_WORKDIR="${RUNNER_HOME}/_work"
ENV RUNNER_TGZ="actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz"

# Install required packages: 
#   - curl: to download the runner 
#   - ca-certificates: in case you need TLS 
#   - jq: helpful in scripts 
#   - docker.io: the Docker CLI 
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
        docker.io \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user "actions" to run the runner
RUN useradd --create-home actions && \
    mkdir -p ${RUNNER_HOME} && \
    chown -R actions:actions ${RUNNER_HOME}

USER actions
WORKDIR $RUNNER_HOME

# Download and extract the GitHub Runner
RUN curl -o ${RUNNER_TGZ} -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_TGZ} && \
    tar xzf ${RUNNER_TGZ} && \
    rm -f ${RUNNER_TGZ}

# Copy our entrypoint script (as root, then correct perms)
USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown actions:actions /entrypoint.sh
# USER actions

# By default, this directory is where runner will do builds
RUN mkdir -p ${RUNNER_WORKDIR}

# Use our entrypoint (which runs config.sh + run.sh)
ENTRYPOINT ["/entrypoint.sh"]
