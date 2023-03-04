## Setup WatchDog

### Bring down Alertmanager and operator
```
// Set pod count to 0 for operator so it does not monitor prometheus stack
kubectl scale deployments --replicas=0 -n monitoring kube-prometheus-stack-operator
// Bring Down the Alertmanager
kubectl scale statefulsets --replicas=0 -n monitoring alertmanager-kube-prometheus-stack-alertmanager
```

- Check the [HealthCheck.io](https://healthchecks.io/checks/bdc7a25a-f522-4ccc-b801-2ee226e0c03d/details/?urls=uuid)
- Should show up issue/red after 2 mins

### Bring up Alertmanager and operator
```
// Set pod count to 1 for operator so it does not monitor prometheus stack
kubectl scale deployments --replicas=1 -n monitoring kube-prometheus-stack-operator
// Bring Down the Alertmanager
kubectl scale statefulsets --replicas=1 -n monitoring alertmanager-kube-prometheus-stack-alertmanager
```

- Check the [HealthCheck.io](https://healthchecks.io/checks/bdc7a25a-f522-4ccc-b801-2ee226e0c03d/details/?urls=uuid)
- Should show up green after 2 mins
