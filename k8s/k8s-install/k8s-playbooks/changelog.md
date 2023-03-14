## 更新记录

<details>
<summary>问题修复20221223</summary>

```

1. ingress-nginx 版本更新，旧版本依赖远程helm仓库，目前仓库中已删除，修改为本地charts包安装，bitnami 9.2.6
2. bug修复，安装依赖软件缺少nfs相关组件步骤，当服务器默认没有nfs时，会导致nfs类型pvc无法使用


```

</details>

