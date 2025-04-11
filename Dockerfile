# Fase 1: compila con toolchain basata su UBI8
FROM registry.access.redhat.com/ubi8/go-toolset:1.22 as builder

WORKDIR /src
COPY . .

USER root

# Scarica OCB
RUN curl --proto '=https' --tlsv1.2 -fL -o ocb https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/cmd%2Fbuilder%2Fv0.119.0/ocb_0.119.0_linux_amd64

# Rendi eseguibile
RUN chmod 0777 ocb

# Compila il binario con OCB
RUN ./ocb --config builder-config.yaml --output-path /src/build

# Verifica se il binario è stato creato
RUN ls -l /src/build

# Fase 2: immagine finale minimale basata su UBI8
FROM registry.redhat.io/ubi8/ubi-minimal

RUN microdnf install -y openssl systemd && microdnf clean all

# Copia il binario compilato dalla fase 1
COPY --from=builder /src/build/otelcol-dev /usr/bin/opentelemetry-collector

# Crea utente e gruppo
ARG USER_UID=1001
RUN useradd -u ${USER_UID} otelcol && usermod -a -G systemd-journal otelcol
USER ${USER_UID}

# Esponi le porte usate da OpenTelemetry
EXPOSE 4317 4318 8888 55679 9411

# Comando di avvio
ENTRYPOINT ["/usr/bin/opentelemetry-collector"]
CMD ["--config", "/conf/collector.yaml"]
