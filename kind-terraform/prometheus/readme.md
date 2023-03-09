

```
helm template kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --version 45.3.0 \
  -f prometheus-values.yaml \
  > ./manifests/prom.yaml
```