default:
    @just --list --unsorted

create:
    #!/usr/bin/env bash
    cd kind-terraform
    terraform init
    ./dev.sh

recreate:
    #!/usr/bin/env bash
    cd kind-terraform
    terraform destroy -auto-approve
    ./dev.sh

destroy cluster:
    kind delete cluster -n dev
    kind delete cluster -n devops

build-jenkins:
    docker build -t amitkshirsagar13/devops-jenkins:2.391 ./jenkins
    docker push amitkshirsagar13/devops-jenkins:2.391

reset-jenkins:
    kubectl delete -f ./jenkins/jenkins-service.yaml
    kubectl create -f ./jenkins/jenkins-service.yaml

gpush message:
    git add . && git commit -m "{{message}}" && git push

start-vault:
    mkdir -p vault/volumes/config
    mkdir -p vault/volumes/file
    mkdir -p vault/volumes/logs
    ./vault/setup-vault.sh

kubeA:
    kubectl get pods,svc,ingress -A

kube ns:
    kubectl get pods,svc,ingress -n {{ns}}

pgA:
    kubectl get pods -A

pg ns:
    kubectl get pods -n {{ns}}

pd ns pod:
    kubectl describe pods -n {{ns}} {{pod}}

k type ns:
    kubectl get {{type}} -n {{ns}}

kd type ns item:
    kubectl describe {{type}} -n {{ns}} {{item}}

logs ns pod:
    kubectl logs -n {{ns}} {{pod}} | tee pod.log

ksh ns pod:
    kubectl exec -n {{ns}} -it {{pod}} -- /bin/sh

kbash ns pod:
    kubectl exec -n {{ns}} -it {{pod}} -- /bin/bash