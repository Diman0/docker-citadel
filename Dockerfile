# Citadel as Docker image build using easyinstall
#
FROM debian:latest
ARG DEBIAN_FRONTEND=noninteractive
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
 apt-get autoremove -y

WORKDIR /root

COPY install /root/install

RUN ./install

COPY supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir /var/log/supervisor_log

EXPOSE 25 80 110 143 4433 465 587 993 995

ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
