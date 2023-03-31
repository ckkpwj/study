## 1. bitnami（镜像源是docker.io，可以直接使用）

> chart: https://github.com/bitnami/charts/tree/master/bitnami/nginx-ingress-controller   \
> 9.3.24版本：https://github.com/bitnami/charts/tree/19e4632397176172c143a226ec0e30e0a1bcb86c/bitnami/nginx-ingress-controller
> 

#### Prerequisites
Kubernetes 1.20+
Helm 3.2.0+


```shell
# 在values.yaml config 添加自定义配置
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install nginx-ingress-controller bitnami/nginx-ingress-controller --version=9.3.24 -f values.yaml \
-n ingress-nginx --create-namespace \
--set ingressClassResource.default=true \
--set kind=DaemonSet \
--set daemonset.useHostPort=true \
--set hostNetwork=true \
--set dnsPolicy=ClusterFirstWithHostNet  \
--set service.type=ClusterIP \
--set defaultBackend.enabled=false


# 开启prometheus metrics
--set metrics.enabled=true \
--set metrics.serviceMonitor.enabled=true \

# 在原基础上升级
helm get values -n ingress-nginx nginx-ingress-controller | helm upgrade \
-n ingress-nginx nginx-ingress-controller bitnami/nginx-ingress-controller \
--set defaultBackend.enabled=true \
--version=9.3.24 \
-f -
```
