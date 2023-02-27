## Vault Installation

### Create Manifests

```
mkdir manifests

helm search repo hashicorp/consul --versions  

helm template consul hashicorp/consul \
  --namespace vault \
  --version 1.0.4 \
  -f consul-values.yaml \
  > ./manifests/consul.yaml

kubectl create ns vault
kubectl apply -f ./manifests/consul.yaml
```

### Certs
- Create Certificates
[Certs Creation](./tls/cert.md)

- Create Secrets
```
kubectl -n vault create secret tls tls-ca \
 --cert ./tls/ca.pem  \
 --key ./tls/ca-key.pem

kubectl -n vault create secret tls tls-server \
  --cert ./tls/vault.pem \
  --key ./tls/vault-key.pem
```

### Setup Vault

```


helm search repo hashicorp/vault --versions  

helm template vault hashicorp/vault \
  --namespace vault \
  --version 0.23.0 \
  -f vault-values.yaml \
  > ./manifests/vault.yaml

kubectl apply -f ./manifests/vault.yaml

```

### Init vault and Unseal

```
kubectl -n vault exec -it vault-0 -- sh

vault operator init
vault operator unseal

kubectl -n vault exec -it vault-0 -- vault status
```
