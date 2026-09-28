# PerfScale Helm Charts

Helm charts for running [PerfScale](https://github.com/Perfscale/perfscale) load tests on Kubernetes.

## Charts

| Chart | Description |
|-------|-------------|
| [perfscale](./perfscale/) | The OSS load-testing CLI as a one-shot Job or a scheduled CronJob |

## Usage

### Add the Helm repository

```bash
$ helm repo add perfscale https://raw.githubusercontent.com/Perfscale/charts/main/
$ helm repo update
```

### Search available charts

```bash
$ helm search repo perfscale
```

### Install a chart

```bash
# One-shot smoke run (self-contained SQLite scenario — no network needed)
$ helm install smoke perfscale/perfscale

# Nightly load test from your own scenario
$ helm install nightly perfscale/perfscale \
    --set schedule="0 3 * * *" \
    --set-file scenario.test=my.test.yaml \
    --set-file scenario.config=my.config.yaml
```

See the chart's [values.yaml](./perfscale/values.yaml) for the full surface
(engine flavors, library cache PVC, resource limits, extra CLI args).

## Development

### Prerequisites

- [Helm](https://helm.sh/docs/intro/install/) v3.x
- [ct (chart-testing)](https://github.com/helm/chart-testing) (optional, for linting)

### Lint a chart

```bash
$ helm lint perfscale/
```

### Render templates locally

```bash
$ helm template my-release perfscale/
```

## Releases

Charts are released automatically via GitHub Actions when a chart version is bumped.
chart-releaser publishes each chart as a GitHub Release asset and maintains the
repo index at [`index.yaml`](./index.yaml) on `main`.

See [RELEASES](https://github.com/Perfscale/charts/releases) for the full changelog.
