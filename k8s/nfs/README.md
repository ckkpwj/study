### 1. 安装nfs服务端（在存储服务器执行）
```bash
#存储服务器安装nfs服务
yum -y install nfs-utils
apt-get install nfs-kernel-server

#在存储服务器中，创建挂载目录
mkdir -p /data/kubernetes

#编辑nfs配置文件，指定的目录允许指定的来源IP或者网段访问
vim /etc/exports
/data/kubernetes 192.168.1.0/24(rw,async,no_root_squash)

#重启nfs
systemctl stop nfs-server
systemctl stop rpcbind
systemctl start rpcbind
systemctl start nfs-server
systemctl enable nfs-server
systemctl enable rpcbind

#查看是否正确配置服务
exportfs -arv && showmount -e 
```

### 2. 部署nfs存储类（在k8s控制端执行，需要先安装helm）
```bash
# https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/tree/master/charts/nfs-subdir-external-provisioner
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm install nfs-client nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
-n nfs-client-provisioner --create-namespace \
--set image.repository=willdockerhub/nfs-subdir-external-provisioner \
--set image.tag=v4.0.2 \
--set nfs.server=192.168.2.11 \
--set nfs.path=/data/kubernetes \
--set storageClass.name=nfs-client \
--set storageClass.defaultClass=true 
```

### 3. 其他
- 设置为默认存储类
```shell
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

```


- 如果有防火墙，则需要放通111 2049 和另外三个服务的端口，这三个服务端口随机，需要配置固定https://blog.csdn.net/weixin_39840153/article/details/116624759
