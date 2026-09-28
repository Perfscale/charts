# PerfScale Helm Charts

This repository contains Helm charts for deploying PerfScale services on Kubernetes.

## Charts

| Chart | Description |
|-------|-------------|
| [perfscaled](./perfscaled/) | Rust machine agent |

## Usage

### Add the Helm repository

```bash
$ helm repo add perfscale https://charts.perfscale.su/
$ helm repo update
```

### Search available charts

```bash
$ helm search repo perfscale
```

### Install a chart

```bash
$ helm upgrade --install <release-name> perfscale/<chart-name>
```

### Install with custom values

```bash
$ helm upgrade --install <release-name> perfscale/<chart-name> \
    --namespace <namespace> \
    --create-namespace \
    -f my-values.yaml
```

## Development

### Prerequisites

- [Helm](https://helm.sh/docs/intro/install/) v3.x
- [helm-unittest](https://github.com/helm-unittest/helm-unittest) (optional, for unit tests)
- [ct (chart-testing)](https://github.com/helm/chart-testing) (optional, for linting)

### Lint a chart

```bash
$ helm lint controlplane/
```

### Render templates locally

```bash
$ helm template my-release controlplane/ -f controlplane/values.yaml
```

### Run unit tests

```bash
$ helm unittest controlplane/
```

## Releases

Charts are released automatically via GitHub Actions when a chart version is bumped.
Packaged charts are published to GitHub Pages at `https://charts.perfscale.io/`.

See [RELEASES](https://github.com/perfscale-org/charts/releases) for the full changelog.
