# 安装nginx-controller
```shell

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
kubectl create ns ingress-nginx
helm upgrade --install nginx-ingress-controller bitnami/nginx-ingress-controller -n ingress-nginx --version=9.2.2 -f  ingress-values.yaml \
--set ingressClassResource.default=true \
--set kind=DaemonSet \
--set daemonset.useHostPort=true \
--set hostNetwork=true \
--set dnsPolicy=ClusterFirstWithHostNet  \
--set service.type=ClusterIP \
--set defaultBackend.enabled=false
```