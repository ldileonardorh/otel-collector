# ---------- Stage 1: Build the custom collector binary ----------
FROM brew.registry.redhat.io/rh-osbs/openshift-golang-builder:rhel_8_golang_1.23@sha256:0a070e4a8f2698b6aba3630a49eb995ff1b0a182d0c5fa264888acf9d535f384 AS builder

WORKDIR /opt/app-root/src
USER root

# Copy the output from your OCB build
# This assumes you ran `ocb --config builder-config.yaml` and it created otelcol-dev
COPY otelcol-dev/otelcol-dev /opt/app-root/src/opentelemetry-collector

# Optional FIPS runtime check script if needed
# COPY fips_check.sh .
# RUN ./fips_check.sh

# ---------- Stage 2: Runtime ----------
FROM registry.redhat.io/ubi8/ubi-minimal:latest@sha256:33161cf5ec11ea13bfe60cad64f56a3aa4d893852e8ec44b2fd2a6b40cc38539

WORKDIR /

# Install dependencies needed for journaldreceiver (systemd)
RUN microdnf update -y && \
    microdnf install openssl systemd -y && \
    microdnf clean all

# Copy the compiled collector binary
COPY --from=builder /opt/app-root/src/opentelemetry-collector /usr/bin/opentelemetry-collector

# Copy your custom collector configuration
# COPY builder-config.yaml /etc/otelcol/config.yaml

# Licensing (optional for Red Hat preflight)
#RUN mkdir /licenses
#COPY redhat-opentelemetry-collector/LICENSE /licenses/.

# Create collector user with proper group for journald access
ARG USER_UID=1001
RUN useradd -u ${USER_UID} otelcol && usermod -a -G systemd-journal otelcol
USER ${USER_UID}

# Define container entrypoint
ENTRYPOINT ["/usr/bin/opentelemetry-collector"]
CMD ["--config", "/etc/otelcol/config.yaml"]

# Optional: Add OpenShift/Operator service exposure hints
LABEL com.redhat.component="opentelemetry-collector-container" \
      name="custom/opentelemetry-collector-rhel8" \
      summary="Custom OpenTelemetry Collector" \
      description="Custom OTel Collector with OCB-built binary and monitoring port" \
      io.k8s.description="Custom OTel Collector" \
      io.openshift.expose-services="4317:otlp-grpc,4318:otlp-http,8888:monitoring" \
      io.openshift.tags="tracing" \
      io.k8s.display-name="OpenTelemetry Collector (Custom)"

