default:
    @just --list --unsorted

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

podsA:
    kubectl get pods -A

pods ns:
    kubectl get pods -n {{ns}}

kubeA:
    kubectl get pods,svc,ingress -A

kube ns:
    kubectl get pods,svc,ingress -n {{ns}}