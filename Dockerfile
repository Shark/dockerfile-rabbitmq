FROM ubuntu:xenial

RUN set -x && \
    rabbitmq_version="3.6.2" && \
    rabbitmq_web_mqtt_revision="3b6a09b" && \
    rabbitmq_web_mqtt_sha256="63eb88f986ab47340ecf0c16997924b711c4baff35e99afffe255b92336f7d17" && \
    apt-get update && \
    apt-get install -y --no-install-recommends wget bzip2 ca-certificates erlang-nox logrotate socat && \
    tempdir="$(mktemp -d)" && \
    cd "$tempdir" && \
    wget -O rabbitmq.deb "https://rabbitmq.com/releases/rabbitmq-server/v${rabbitmq_version}/rabbitmq-server_${rabbitmq_version}-1_all.deb" && \
    wget -O rabbitmq.deb.asc "https://rabbitmq.com/releases/rabbitmq-server/v3.6.2/rabbitmq-server_${rabbitmq_version}-1_all.deb.asc" && \
    gpg --keyserver pgp.mit.edu --recv-keys 0x056E8E56 && \
    gpg --verify rabbitmq.deb.asc rabbitmq.deb && \
    wget -O rabbitmq_web_mqtt.tar.bz2 "https://f001.backblaze.com/file/sh4rk-pub/dockerfile/rabbitmq/rabbitmq_web_mqtt-${rabbitmq_web_mqtt_revision}.tar.bz2" && \
    rabbitmq_web_mqtt_actual_sha256=$(sha256sum rabbitmq_web_mqtt.tar.bz2) && \
    echo "sha256 expected: ${rabbitmq_web_mqtt_sha256}  rabbitmq_web_mqtt.tar.bz2" && \
    echo "sha256 actual:   ${rabbitmq_web_mqtt_actual_sha256}" && \
    if [ "${rabbitmq_web_mqtt_sha256}  rabbitmq_web_mqtt.tar.bz2" != "$rabbitmq_web_mqtt_actual_sha256" ]; then exit 999; fi && \
    dpkg -i rabbitmq.deb && \
    tar xvf rabbitmq_web_mqtt.tar.bz2 -C "/usr/lib/rabbitmq/lib/rabbitmq_server-${rabbitmq_version}/plugins/" && \
    cd / && \
    rm -r "$tempdir" && \
    apt-get autoremove -y --purge wget bzip2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER rabbitmq
EXPOSE 5672 15672 1883 8883 15675
VOLUME ["/var/lib/rabbitmq", "/etc/rabbitmq"]
ENTRYPOINT ["/usr/sbin/rabbitmq-server"]
