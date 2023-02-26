#!/bin/sh
cat > jenkins-service-account.yaml << EOF
---
apiVersion: v1
kind: Namespace
metadata:
  name: cicd
  labels:
    name: cicd
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-robot
  namespace: cicd
automountServiceAccountToken: false
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins-admin
rules:
- apiGroups:
  - ""
  - apps
  - extensions
  - networking.k8s.io
  resources:
  - pods
  - status
  - secrets
  - pods/log
  - services
  - configmaps
  - namespaces
  - deployments
  - replicasets
  - serviceaccounts
  - persistentvolumeclaims
  - ingresses
  verbs:
  - get
  - list
  - watch
  - create
  - update
  - patch
  - delete
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins-robot-binding
roleRef:
  kind: ClusterRole
  name: jenkins-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: jenkins-robot
  namespace: cicd
EOF
kubectl apply -f jenkins-service-account.yaml
JENKINS_ROBOT=`kubectl -n cicd get serviceaccount jenkins-robot -o go-template --template='{{range .secrets}}{{.name}}{{"\n"}}{{end}}'`
kubectl -n cicd get secrets $JENKINS_ROBOT -o go-template --template '{{index .data "token"}}' | base64 -d > secrets/jenkins-tokens/kubernetes-service-account-secret

