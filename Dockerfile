FROM ubuntu:17.10
MAINTAINER Chris Collins <collins.christopher@gmail.com>

ENV PKGS python python-pip nginx runit

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y $PKGS

RUN pip install mkdocs
ADD default /etc/nginx/sites-enabled/default

RUN mkdir -p /etc/service/nginx
ADD nginx.run /etc/service/nginx/run
RUN chmod -R a+x /etc/service/nginx

RUN mkdir -p /etc/service/mkdocs
ADD mkdocs.run /etc/service/mkdocs/run
RUN chmod -R a+x /etc/service/mkdocs

EXPOSE 80
