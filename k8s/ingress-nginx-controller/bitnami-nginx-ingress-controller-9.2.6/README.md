## nginx-ingress-controller（镜像源是docker.io，可以直接使用）

> chart: https://github.com/bitnami/charts/tree/master/bitnami/nginx-ingress-controller   \
> 9.2.6版本：https://github.com/bitnami/charts/tree/ff3cf617a1680509b0f3855d17c4ccff7b29a0ff/bitnami/nginx-ingress-controller
> 

#### Prerequisites
Kubernetes 1.19+
Helm 3.2.0+


```shell
# 在values.yaml config 添加自定义配置
helm upgrade --install nginx-ingress-controller ./nginx-ingress-controller-9.2.6.tgz -f values.yaml \
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

# 在原基础上升级命令格式参考
helm get values -n ingress-nginx nginx-ingress-controller | helm upgrade \
-n ingress-nginx nginx-ingress-controller ./nginx-ingress-controller-9.2.6.tgz \
--set defaultBackend.enabled=true \
-f -
```
