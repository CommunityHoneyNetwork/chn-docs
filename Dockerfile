FROM centos:7
MAINTAINER Chris Collins <collins.christopher@gmail.com>

COPY RPM-GPG-KEY-EPEL* /etc/pki/rpm-gpg/
RUN yum install -y epel-release \
      && yum install -y python-pip \
      && yum clean all \
      && rm -rf /var/cache/yum

RUN pip install mkdocs
COPY mkdocs.run /mkdocs.run

EXPOSE 8080
USER 1000

CMD [ "/mkdocs.run" ]
