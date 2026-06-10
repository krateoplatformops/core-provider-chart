# Core Provider Helm Chart

This is a [Helm Chart](https://helm.sh/docs/topics/charts/) for [Krateo Core Provider](https://github.com/krateoplatformops/core-provider).

## How to install

```sh
helm repo add krateo https://charts.krateo.io
helm repo update krateo
helm install krateo-core-provider krateo/core-provider 
```

## logs-ingester compatibility

All pods deployed by this chart (core-provider, chart-inspector and the dynamically
created CDC controllers) carry the shared label `app.kubernetes.io/part-of: krateo`, so a
single [`logs-ingester`](https://github.com/krateoplatformops/logs-ingester) instance can
collect their logs. Deploy the ingester in the same namespace and set
`SELECTOR=app.kubernetes.io/part-of=krateo`.

See [docs/logs-ingester-compatibility.md](docs/logs-ingester-compatibility.md) for details.
