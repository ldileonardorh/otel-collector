## Download ocb from repo (v0.119.0)

```bash
curl --proto '=https' --tlsv1.2 -fL -o ocb https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/cmd%2Fbuilder%2Fv0.119.0/ocb_0.119.0_linux_amd64
```

## Build

```bash 
./ocb --config builder-config.yaml
```

## Build Docker image

```bash
podman build -t otelcollector-cst:0.119.0 .
```
