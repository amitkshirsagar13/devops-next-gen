### Fluent-Bit

- [Fluent-Bit](https://artifacthub.io/packages/helm/fluent/fluent-bit)

```

helm show chart https://fluent.github.io/helm-charts/fluentd

helm repo list
helm show repo fluent/fluent-bit

kubectl create namespace logging
helm uninstall --namespace logging fluent-bit
helm install --namespace logging fluent-bit fluent/fluent-bit -f ./fluentd/fluentbit-values.yaml
helm upgrade --namespace logging fluent-bit fluent/fluent-bit -f ./fluentd/fluentbit-values.yaml

sudo sysctl -w fs.inotify.max_user_instances=1024
sudo sysctl -w fs.inotify.max_user_watches=12288

```
