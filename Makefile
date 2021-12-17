THIS_FILE := $(lastword $(MAKEFILE_LIST))

SHELL := /bin/bash

.PHONY: help
help:
	make -pRrq -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
.PHONY:  cert-manager-up cert-manager-delete kuber-dash-token
cert-manager-up:
	sudo kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml
cert-manager-delete:
	sudo kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml
# Kubernetes Dashboard
.PHONY: kuber-dash-install kuber-dash-delete kuber-dash-token
kuber-dash-install:
	sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml
	sudo kubectl apply -f ./kuber-dash/user.yml
	sudo kubectl apply -f ./kuber-dash/kuber-dashboard-traefik.yml
kuber-dash-delete:
	sudo kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml
	sudo kubectl delete -f ./kuber-dash/user.yml
kuber-dash-token:
	sudo ./kuber-dash/get-token.sh
# Traefik Dashboard
.PHONY:
traefik-dash-install:
	sudo kubectl apply -f ./traefik-dash/001-crd.yaml
	sudo kubectl apply -f ./traefik-dash/002-rbac.yaml
	sudo cp 
.PHONY: get-all
get-all:
	sudo kubectl get all --all-namespaces


# .PHONY: traefik-forward
# traefik-forward:
# 	sudo kubectl port-forward -n kube-system "$(sudo kubectl get pods -n kube-system| grep '^traefik-' | awk '{print $1}')" 8588:9000