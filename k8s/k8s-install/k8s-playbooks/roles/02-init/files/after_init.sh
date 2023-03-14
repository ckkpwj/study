#!/bin/bash

mkdir -p $HOME/.kube
mv $HOME/.kube/config $HOME/.kube/config-bak-$(date +%Y%m%d)
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
source <(kubeadm completion bash)
echo "source <(kubeadm completion bash)" >> ~/.bashrc