### elasticsearch
```
helm repo add elastic https://helm.elastic.co
curl -O https://raw.githubusercontent.com/elastic/Helm-charts/master/elasticsearch/examples/minikube/values.yaml

helm install --namespace logging elasticsearch elastic/elasticsearch -f ./elastic-values.yaml
```

### kibana
