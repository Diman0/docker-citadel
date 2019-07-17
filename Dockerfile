# Citadel as Docker image build using easyinstall
#
FROM debian:stretch
ARG DEBIAN_FRONTEND=noninteractive

COPY install /root/install
WORKDIR /root

RUN apt-get update && apt-get install -y \
 build-essential \
 curl \
 g++ \
 gettext \
 libcurl4-openssl-dev \
 libexpat1-dev \
 libical-dev \
 libldap2-dev \
 libssl-dev \
 shared-mime-info \
 supervisor \
 zlib1g-dev && \
 apt-get clean -y && \
 apt-get autoclean -y && \
 apt-get autoremove -y && \
 rm -rf /var/lib/apt/lists/* && \
 ./install && \
 apt-get remove -y \
 build-essential \
 curl \
 g++ && \
 apt-get clean -y && \
 apt-get autoclean -y && \
 apt-get autoremove -y

COPY supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir /var/log/supervisor_log

EXPOSE 25 80 110 143 465 587 993 995

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
