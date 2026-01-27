FROM ubuntu:24.04
LABEL maintainer="hello@javiertoledos.dev"

RUN apt-get update && apt-get install -y \
  bind9 \
  bind9-host \
  bind9-utils \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["named", "-u", "bind", "-g"]