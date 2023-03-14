#!/bin/bash

kubeadm init --config /root/kubeadm-config.yaml --upload-certs &> /root/kubeadm-init.log