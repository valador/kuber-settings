THIS_FILE := $(lastword $(MAKEFILE_LIST))

SHELL := /bin/bash

GITHUB_DASH_URL = https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD := $(shell curl -w '%{url_effective}' -I -L -s -S $(GITHUB_DASH_URL)/latest -o /dev/null | sed -e 's|.*/||')

GITHUB_CERTMANAGER_URL = https://github.com/cert-manager/cert-manager/releases
VERSION_CERTMANAGER_DASHBOARD := $(shell curl -w '%{url_effective}' -I -L -s -S $(GITHUB_CERTMANAGER_URL)/latest -o /dev/null | sed -e 's|.*/||')

.PHONY: help
help:
	make -pRrq -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
.PHONY: k3s-install k3s-delete
k3s-install:
	curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest sh -
k3s-delete:
	k3s-uninstall.sh
	sudo rm -rf /var/lib/rancher
.PHONY:  cert-manager-install cert-manager-delete
cert-manager-install:
	sudo k3s kubectl create -f https://github.com/jetstack/cert-manager/releases/download/$(VERSION_CERTMANAGER_DASHBOARD)/cert-manager.yaml
cert-manager-delete:
	sudo k3s kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/$(VERSION_CERTMANAGER_DASHBOARD)/cert-manager.yaml
# Kubernetes Dashboard
.PHONY: kuber-dash-install kuber-dash-delete kuber-dash-token kuber-dash-kubeconfig
kuber-dash-install:
	sudo k3s kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/$(VERSION_KUBE_DASHBOARD)/aio/deploy/recommended.yaml
	sudo k3s kubectl create -f ./kuber-dash/user.yml
	sudo k3s kubectl create -f ./kuber-dash/kuber-dashboard-traefik.yml
kuber-dash-delete:
# sudo kubectl delete -f ./kuber-dash/user.yml
	sudo kubectl delete -f ./kuber-dash/kuber-dashboard-traefik.yml
	sudo k3s kubectl -n kubernetes-dashboard delete serviceaccount admin-user
	sudo k3s kubectl -n kubernetes-dashboard delete clusterrolebinding admin-user
	sudo k3s kubectl delete ns kubernetes-dashboard
	sudo k3s kubectl delete clusterrolebinding kubernetes-dashboard
	sudo k3s kubectl delete clusterrole kubernetes-dashboard
kuber-dash-token:
# sudo k3s kubectl -n kubernetes-dashboard create token admin-user
	sudo ./kuber-dash/get-token.sh
kuber-dash-kubeconfig:
# need delete after uninstall dashboard?
	sudo ./kuber-dash/get-kubeconfig.sh
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