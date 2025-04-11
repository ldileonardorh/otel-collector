# Build Custom OpenTelemetry Collector for Red Hat Openshift 

This project describes the procedure to build a custom otel collector (based on official RHEL image) compatible for Red Hat build of Open Telemetry Operator v0.119.0

## Build Locally
It is possible to build otel locally by downloading ocb (otel collector builder)
Follow steps below to install locally and execute GO files

### Download ocb from repo (v0.119.0)

```bash
curl --proto '=https' --tlsv1.2 -fL -o ocb https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/cmd%2Fbuilder%2Fv0.119.0/ocb_0.119.0_linux_amd64
```

### Build

```bash 
./ocb --config builder-config.yaml
```

## Build OCP Compatible image
Execute the following command to create a custom docker image.

```bash
podman build -t otelcollector-cst:0.119.0 .
```

The build process automatically compiles GO and build container image