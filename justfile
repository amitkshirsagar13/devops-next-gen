defaultCluster := 'dev'

default:
    @just --list --unsorted

du:
    du -h /var/lib/docker

clean:
    docker volume prune -f
    docker container prune -f
    docker image prune

create:
    #!/usr/bin/env bash
    cd kind-terraform
    rm -r .terraform*
    rm -r terraform*
    terraform init
    ./dev.sh

recreate:
    #!/usr/bin/env bash
    cd kind-terraform
    rm -r .terraform*
    rm -r terraform*
    terraform destroy -auto-approve
    terraform init
    ./dev.sh

t-destroy:
    #!/usr/bin/env bash
    cd kind-terraform
    terraform destroy -auto-approve
    rm -r .terraform*
    rm -r terraform*

destroy cluster:
    kind delete  -n {{cluster}}

build-jenkins:
    docker build -t amitkshirsagar13/devops-jenkins:2.391 ./jenkins
    docker push amitkshirsagar13/devops-jenkins:2.391

reset-jenkins:
    kubectl delete -f ./jenkins/jenkins-service.yaml
    kubectl create -f ./jenkins/jenkins-service.yaml

commit message='default commit':
    git add . && git commit -m "{{message}}" && git push

start-vault:
    mkdir -p vault/volumes/config
    mkdir -p vault/volumes/file
    mkdir -p vault/volumes/logs
    ./vault/setup-vault.sh

kubeA clusterName=defaultCluster:
    kubectl get pods,svc,ingress -A --context=kind-{{clusterName}}

kube ns clusterName=defaultCluster:
    kubectl get pods,svc,ingress -n {{ns}} --context=kind-{{clusterName}}

pgA clusterName=defaultCluster:
    kubectl get pods -A --context=kind-{{clusterName}}

pg ns clusterName=defaultCluster:
    kubectl get pods -n {{ns}} --context=kind-{{clusterName}}

pd ns pod clusterName=defaultCluster:
    kubectl describe pods -n {{ns}} {{pod}} --context=kind-{{clusterName}}

k type ns clusterName=defaultCluster:
    kubectl get {{type}} -n {{ns}} --context=kind-{{clusterName}}

kd type ns item clusterName=defaultCluster:
    kubectl describe {{type}} -n {{ns}} {{item}} --context=kind-{{clusterName}}

logs ns pod clusterName=defaultCluster:
    kubectl logs -n {{ns}} {{pod}} --context=kind-{{clusterName}} | tee pod.log

ksh ns pod clusterName=defaultCluster:
    kubectl exec -n {{ns}} -it {{pod}} --context=kind-{{clusterName}} -- /bin/sh

kbash ns pod clusterName=defaultCluster:
    kubectl exec -n {{ns}} -it {{pod}} --context=kind-{{clusterName}} -- /bin/bash