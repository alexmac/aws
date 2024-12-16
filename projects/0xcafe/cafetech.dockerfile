FROM public.ecr.aws/debian/debian:unstable-slim

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    ca-certificates \
    dumb-init \
    python3 \
    python3-venv \
    wget \
    && apt-get clean

RUN wget -qO- https://astral.sh/uv/install.sh | sh
RUN mv /root/.local/bin/uv* /usr/local/bin/
EXPOSE 8080

WORKDIR /usr/local/aws/projects/0xcafe/
COPY pyproject.toml* ./
RUN uv venv && uv sync

COPY cafetech ./cafetech
COPY static ./static
COPY templates ./templates
COPY blog_server.py ./

ENV PYTHONPATH=.

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD uv run blog_server.py
