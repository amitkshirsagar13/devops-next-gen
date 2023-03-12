#!/usr/bin/env sh

set -e
terraform init
terraform apply -auto-approve

printf "\nWaiting for the echo web server service... \n"
sleep 10

kubectl apply -f kubernetes-ingress.yaml

printf "\nYou should see 'echo' as a reponse below (if you do the ingress is working):\n"
curl http://echo-read.localtest.me/echo
curl http://echo-write.localtest.me/echo1
curl http://echo-write.localtest.me/echo2
