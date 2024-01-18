FROM public.ecr.aws/debian/debian:unstable

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    ca-certificates \
    wget \
    python3 \
    python3-pip \
    dumb-init \
    && apt-get clean

RUN python3 -m pip install --break-system-packages -U pipenv
EXPOSE 8080

WORKDIR /usr/local/aws/projects/0xcafe/
COPY Pipfile* ./
RUN pipenv install

COPY cafetech ./cafetech
COPY favicon ./favicon
COPY templates ./templates
COPY blog_server.py ./
COPY robots.txt ./
COPY tailwind.css ./

ENV PYTHONPATH=.

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD pipenv run python3 blog_server.py
