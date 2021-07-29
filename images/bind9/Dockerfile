FROM ubuntu:20.04
LABEL maintainer="hello@javiertoledos.dev"

RUN apt-get update && apt-get install -y \
  bind9=1:9.16.1-0ubuntu2.8 \
  bind9-host=1:9.16.1-0ubuntu2.8 \
  bind9utils \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["named", "-u", "bind", "-g"]