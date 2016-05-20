FROM ubuntu:xenial

RUN set -x && \
    rabbitmq_version="3.6.2" && \
    rabbitmq_web_mqtt_revision="3b6a09b" && \
    rabbitmq_sha256="87217c0b135c6705f1d9ac2fcdbc355eeb3b0f53562c4f430e79861b0b7057b8" && \
    rabbitmq_web_mqtt_sha256="7cb9869759c8493e28a7bcf3c25e3b9f2e0eedb14ae279f39055cbfe67d1a094" && \
    apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates erlang-nox logrotate socat && \
    tempdir="$(mktemp -d)" && \
    cd "$tempdir" && \
    wget -O rabbitmq.deb "https://rabbitmq.com/releases/rabbitmq-server/v${rabbitmq_version}/rabbitmq-server_${rabbitmq_version}-1_all.deb" && \
    rabbitmq_actual_sha256=$(sha256sum rabbitmq.deb) && \
    echo "sha256 expected: ${rabbitmq_sha256}  rabbitmq.deb" && \
    echo "sha256 actual:   ${rabbitmq_actual_sha256}" && \
    if [ "${rabbitmq_sha256}  rabbitmq.deb" != "$rabbitmq_actual_sha256" ]; then exit 999; fi && \
    wget -O rabbitmq-web-mqtt.ez "https://f001.backblaze.com/file/sh4rk-pub/dockerfile/rabbitmq/rabbitmq_web_mqtt-${rabbitmq_web_mqtt_revision}.ez" && \
    rabbitmq_web_mqtt_actual_sha256=$(sha256sum rabbitmq-web-mqtt.ez) && \
    echo "sha256 expected: ${rabbitmq_web_mqtt_sha256}  rabbitmq-web-mqtt.ez" && \
    echo "sha256 actual:   ${rabbitmq_web_mqtt_actual_sha256}" && \
    if [ "${rabbitmq_web_mqtt_sha256}  rabbitmq-web-mqtt.ez" != "$rabbitmq_web_mqtt_actual_sha256" ]; then exit 999; fi && \
    dpkg -i rabbitmq.deb && \
    mv rabbitmq-web-mqtt.ez "/usr/lib/rabbitmq/lib/rabbitmq_server-${rabbitmq_version}/plugins/" && \
    cd / && \
    rm -r "$tempdir" && \
    apt-get autoremove -y --purge wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER rabbitmq
EXPOSE 5672 15672 1883 8883 15675
VOLUME ["/var/lib/rabbitmq"]
ENTRYPOINT ["/usr/sbin/rabbitmq-server"]
