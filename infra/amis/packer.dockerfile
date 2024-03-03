FROM public.ecr.aws/debian/debian:stable

RUN apt-get update && \
  apt-get install --no-install-recommends -y ca-certificates curl && \
  curl -o /etc/apt/trusted.gpg.d/hashicorp.asc https://apt.releases.hashicorp.com/gpg && \
  echo "deb https://apt.releases.hashicorp.com bookworm main" > /etc/apt/sources.list.d/hashicorp.list

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
      dumb-init \
      jq \
      make \
      packer \
      python3 \
      python3-pip \
    && apt-get clean

RUN pip install -U --break-system-packages awscli

RUN ln -s /usr/bin/sha1sum /usr/bin/shasum

WORKDIR /usr/local/amis
COPY . /usr/local/amis

RUN packer init server.pkr.hcl

ENV PACKER_NO_COLOR=1

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
