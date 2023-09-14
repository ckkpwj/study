# k8s yaml备份工具

- 注意：使用工具导出的yaml和kubectl get -o yaml获取的不完全一致。删除了一些非必要字段，这主要是为了方便迁移。删除的字段列表：

```
["metadata"]["annotations"]["kubectl.kubernetes.io/last-applied-configuration"]
["metadata"]["managedFields"]
["metadata"]["creationTimestamp"]
["metadata"]["generation"]
["metadata"]["annotations"]["deployment.kubernetes.io/revision"]
["metadata"]["resourceVersion"]
["metadata"]["selfLink"]
["metadata"]["uid"]
["spec"]["template"]["metadata"]["creationTimestamp"]
["status"]
["spec"]["clusterIP"]
["spec"]["clusterIPs"]
["metadata"]["annotations"]["pv.kubernetes.io/provisioned-by"]
["spec"]["claimRef"]
["metadata"]["finalizers"]
["metadata"]["annotations"]["pv.kubernetes.io/bind-completed"]
["metadata"]["annotations"]["pv.kubernetes.io/bound-by-controller"]
["metadata"]["annotations"]["volume.beta.kubernetes.io/storage-provisioner"]
["spec"]["template"]["metadata"]["annotations"]["kubectl.kubernetes.io/restartedAt"]
```


```shell
# 执行产生的备份文件在当前目录中，以yaml-开头，以yyyy-mm-dd-HHMM结尾的目录
# 若当前服务器默认python2,执行脚本则会报错 'import yaml' 解决办法: python3 -m pip install PyYAML 再执行备份脚本即可
# 查看帮助
python3 kube-export-yaml.py -h

# 备份resources.list文件中指定的类型在ketanyun命名空间中的所有yaml
python3 kube-export-yaml.py -n ketanyun -f

# 备份ketanyun命名空间中的所有deployment和sts
python3 kube-export-yaml.py -n ketanyun deploy sts

# 从所有命名空间备份qcanvas
python3 kube-export-yaml.py qcanvas -A
```

- 没有python3可以使用export_yaml.sh，但无法处理掉多余字段，导出来的yaml不能直接apply。可以按照上面删除的字段列表手工处理