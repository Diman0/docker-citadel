# Citadel as Docker image build using easyinstall
#
FROM debian:stretch as build
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
 apt-get autoremove -y && \
 rm -rf /var/lib/apt/lists/*

COPY install /root/install
RUN /root/install

FROM debian:stretch
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
 gettext \
 libc6 \
 libcurl3 \
 libev4 \
 libexpat1 \
 libical2 \
 libldap-2.4.2 \
 libssl1.1 \
 netbase \
 openssl \
 shared-mime-info \
 supervisor \
 zlib1g && \
 apt-get clean -y && \
 apt-get autoclean -y && \
 apt-get autoremove -y && \
 rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/citadel/ /usr/local/citadel/
COPY --from=build /usr/local/webcit/ /usr/local/webcit/
COPY --from=build /usr/local/ctdlsupport/ /usr/local/ctdlsupport/
COPY supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir /var/log/supervisor_log

EXPOSE 25 80 110 143 465 587 993 995

ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
