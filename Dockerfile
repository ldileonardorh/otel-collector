FROM registry.access.redhat.com/ubi8/go-toolset:1.23.6 as builder

WORKDIR /src
COPY . .

USER root

RUN curl --proto '=https' --tlsv1.2 -fL -o ocb https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/cmd%2Fbuilder%2Fv0.119.0/ocb_0.119.0_linux_amd64

RUN chmod 0777 ocb

RUN ./ocb --config builder-config.yaml --output-path /src/build

RUN ls -l /src/build

FROM registry.redhat.io/ubi8/ubi-minimal:8.10

RUN microdnf install -y openssl systemd && microdnf clean all

COPY --from=builder /src/build/otelcol-dev /usr/bin/opentelemetry-collector

ARG USER_UID=1001
RUN useradd -u ${USER_UID} otelcol && usermod -a -G systemd-journal otelcol
USER ${USER_UID}

EXPOSE 4317 4318 8888 55679 9411

ENTRYPOINT ["/usr/bin/opentelemetry-collector"]
CMD ["--config", "/conf/collector.yaml"]
