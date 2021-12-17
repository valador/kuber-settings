THIS_FILE := $(lastword $(MAKEFILE_LIST))

SHELL := /bin/bash

.PHONY: help
help:
	make -pRrq -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
.PHONY: k3s-install k3s-delete
k3s-install:
	curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest sh -
k3s-delete:
	k3s-uninstall.sh
	sudo rm -rf /var/lib/rancher
.PHONY:  cert-manager-install cert-manager-delete kuber-dash-token
cert-manager-install:
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
	sudo kubectl delete -f ./kuber-dash/kuber-dashboard-traefik.yml
	sudo kubectl delete -f ./kuber-dash/user.yml
	sudo kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml
kuber-dash-token:
	sudo ./kuber-dash/get-token.sh
# Traefik Dashboard
.PHONY: traefik-dash-install traefik-dash-delete
traefik-dash-install:
	sudo kubectl apply -f ./traefik-dash/001-crd.yaml
	sudo kubectl apply -f ./traefik-dash/002-rbac.yaml
	sudo kubectl apply -f ./traefik-dash/traefik-dashboard-ingressroute.yml
	# sudo cp ./traefik-dash/traefic-config.yaml /var/lib/rancher/k3s/server/manifests/
traefik-dash-delete:
	sudo kubectl delete -f ./traefik-dash/traefik-dashboard-ingressroute.yml
	sudo kubectl delete -f ./traefik-dash/001-crd.yaml
	sudo kubectl delete -f ./traefik-dash/002-rbac.yaml
	# sudo rm /var/lib/rancher/k3s/server/manifests/traefic-config.yaml
.PHONY: get-all
get-all:
	sudo kubectl get all --all-namespaces


# .PHONY: traefik-forward
# traefik-forward:
# 	sudo kubectl port-forward -n kube-system "$(sudo kubectl get pods -n kube-system| grep '^traefik-' | awk '{print $1}')" 8588:9000