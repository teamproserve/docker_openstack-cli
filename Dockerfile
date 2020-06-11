FROM alpine:3.8

LABEL maintainer="jaikema@proserve.nl"

ARG TERRAFORM_VERSION=0.12.26
ARG HELM_VERSION=2.11.0

env OS_AUTH_URL="https://identity.openstack.cloudvps.com/v3"
env OS_PROJECT_ID=""
env OS_TENANT_ID=""
env OS_PROJECT_NAME=""
env OS_TENANT_NAME=""
env OS_USER_DOMAIN_NAME="Default"
env OS_USERNAME=""
env OS_PASSWORD=""
env OS_REGION_NAME="AMS"
env OS_INTERFACE="public"
env OS_IDENTITY_API_VERSION=3
env TERM=xterm-256color

RUN apk add --no-cache --update \
  tzdata \
  bash \
  zsh \
  zsh-vcs \
  less \
  git \
  curl \
  vim \
  coreutils \
  perl \
  openssh-client \
  openssl \
  openssl-dev \
  python-dev \
  py-pip \
  py-setuptools \
  util-linux \
  ca-certificates \
  gcc \
  make \
  musl-dev \
  linux-headers \
  libffi-dev \
  docker \
  ansible \
  && pip install --upgrade pip \
  && pip install --upgrade --no-cache-dir pip jinja2==2.9.5 setuptools python-openstackclient python-cinderclient==4.0.1 openstack-interpreter \ 
  && apk del gcc musl-dev linux-headers \
  && rm -rf /var/cache/apk/*

RUN cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime \
  && echo "Europe/Amsterdam" > /etc/timezone \
  && apk del tzdata

ADD install.sh /root/
RUN sh /root/install.sh && rm -f /root/install.sh && sed -i s/robbyrussell/agnoster/g /root/.zshrc 

RUN curl -OL https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh \
  && sh gitflow-installer.sh \
  && rm -f gitflow-installer.sh \
  && rm -rf gitflow

RUN curl https://run.conduit.io/install | bash

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
  && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && mkdir /usr/lib/custom-terraform-plugins \
  && wget https://releases.hashicorp.com/terraform-provider-vsphere/1.18.3/terraform-provider-vsphere_1.18.3_linux_amd64.zip \
  && unzip terraform-provider-vsphere_1.18.3_linux_amd64.zip -d /usr/lib/custom-terraform-plugins \
  && rm terraform-provider-vsphere_1.18.3_linux_amd64.zip \
  && wget https://releases.hashicorp.com/terraform-provider-openstack/1.28.0/terraform-provider-openstack_1.28.0_linux_amd64.zip \
  && unzip terraform-provider-openstack_1.28.0_linux_amd64.zip -d /usr/lib/custom-terraform-plugins \
  && rm terraform-provider-openstack_1.28.0_linux_amd64.zip \
  && wget https://releases.hashicorp.com/terraform-provider-aws/2.65.0/terraform-provider-aws_2.65.0_linux_amd64.zip \
  && unzip terraform-provider-aws_2.65.0_linux_amd64.zip -d /usr/lib/custom-terraform-plugins \
  && rm terraform-provider-aws_2.65.0_linux_amd64.zip

RUN  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.13.12/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/bin

RUN wget https://kubernetes-helm.storage.googleapis.com/helm-v${HELM_VERSION}-linux-amd64.tar.gz \ 
  && tar xf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
  && cp /linux-amd64/helm /usr/local/bin \
  && chmod +x /usr/local/bin/helm \
  && rm -rvf linux-amd64 \
  && rm helm-v${HELM_VERSION}-linux-amd64.tar.gz

RUN curl -L https://github.com/coreos/container-linux-config-transpiler/releases/download/v0.9.0/ct-v0.9.0-x86_64-unknown-linux-gnu --output /usr/local/bin/ct \
  && chmod +x /usr/local/bin/ct

RUN curl -sSL https://cli.openfaas.com | sh

VOLUME ["/blueprints"]
WORKDIR /blueprints

COPY run.sh /usr/local/bin/run.sh

ENTRYPOINT ["/usr/local/bin/run.sh"] 

