FROM public.ecr.aws/debian/debian:stable

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    ca-certificates \
    dumb-init \
    python3 \
    python3-pip \
    wget \
    && apt-get clean

RUN python3 -m pip install --break-system-packages -U pipenv
EXPOSE 8080

WORKDIR /usr/local/aws/projects/0xcafe/
COPY Pipfile* ./
RUN pipenv install

COPY cafetech ./cafetech
COPY static ./static
COPY templates ./templates
COPY blog_server.py ./

ENV PYTHONPATH=.

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD pipenv run python3 blog_server.py
