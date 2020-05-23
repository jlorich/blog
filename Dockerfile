# --------------------------------
# Base Container
# --------------------------------
FROM ruby:2.7.1-buster as base

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install generic packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils dialog 2>&1 \
    #
    # Verify git, process tools installed
    && apt-get install -y \
        # Dev tookl
        git \
        openssh-client \
        curl \
        unzip \
        #
        # Jekyll/Ruby
        build-essential \
        zlib1g-dev \
        #
        # Combine stderr and stdout to screen
        2>&1

# Set up our workspace directory and copy in the Gemfile
RUN mkdir -p /workspaces/blog/src

WORKDIR /workspaces/blog
COPY ./src/Gemfile ./src/

# Install the specified gems
RUN cd ./src && bundle install


# --------------------------------
# Build Container
# --------------------------------

FROM base as build

RUN mkdir -p /workspaces/blog/src

WORKDIR /workspaces/blog/src

COPY ./src/Gemfile .
RUN bundle install

COPY ./src .


# --------------------------------
# Dev Container
# --------------------------------

FROM base as dev


# Dependency Versions

# Latest version of Terraform may be found at https://www.terraform.io/downloads.html
ARG TERRAFORM_VERSION=0.12.25

# Latest version of Terrform Linter may be found at https://github.com/terraform-linters/tflint/releases
ARG TFLINT_VERSION=0.16.0

# Create a temp directory for downloads
RUN mkdir -p /tmp/downloads

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install Terraform, tflint, and graphviz
RUN curl -sSL -o /tmp/downloads/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip /tmp/downloads/terraform.zip \
    && mv terraform /usr/local/bin \
    && curl -sSL -o /tmp/downloads/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip \
    && unzip /tmp/downloads/tflint.zip \
    && mv tflint /usr/local/bin \
    && cd ~ \ 
    && apt-get install -y graphviz
