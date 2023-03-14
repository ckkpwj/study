# Kubernetes 集群自动部署
- 更新时间：20221223
> 注意事项： \
> 操作系统要求：ubuntu 20.04 ubuntu 22.04 或者centos7.9  \
> master的操作系统必须一致，node可以混合使用 \
> 最多三台master \
> 升级内核需要安装前手动处理  \
> 安装时会关闭防火墙，如有需要可安装后再次开启

## master高可用模式说明

* 使用keepalived做VIP故障切换，这不是任何场景都适用，已知使用云服务器时无法进行VIP切换。使用前需确认，或者在安装后进行故障模拟


### 0、检查服务器配置

- 检查所有服务器的dns配置，避免使用8.8.8.8等外网地址，应使用学校提供的内网dns。学校没有内网dns时，使用国内dns，如阿里的223.5.5.5
- 检查所有服务器的磁盘配置，df -h|lsblk等，确定数据目录
- 如果可以，建议安装之前执行yum upgrade/apt upgrade升级系统软件


### 1、在k8s-master1安装Ansible

- 可手动安装，或者执行`bash before_install.sh`


### 2、修改Ansible文件

```txt
修改hosts文件，根据规划修改对应IP和名称。
修改group_vars/k8s.yml文件
修改ansible.cfg文件，配置登录密钥，ssh端口等
```

## 3、部署k8s集群

```txt
需要root执行，如果涉及普通用户提权操作，加参数-b  
如果服务器密码都一样，可以加参数-k  
如果服务器密码不一样，可以配置到hosts文件，或者使用密钥  
如果可以，建议安装之前执行yum upgrade/apt upgrade升级系统软件
```

```shell
ansible-playbook deploy.yml 
```


## 4、其他
### 4.1 部署控制
如果安装某个阶段失败，可针对性测试.

例如：只运行部署插件
```shell
ansible-playbook -i hosts deploy.yml -uroot -k --tags addons
```

### 4.2 节点扩容
1）修改hosts，添加新节点ip
```shell
vi hosts
...
[newnode]
k8s-node3 ansible_ssh_host=192.168.0.224
```
2）执行部署
```shell
ansible-playbook newnode.yml 
```



# -----------------------------------------------------------------------------------------------
## mariadb主从部署
> ::TODO目前还不完善，默认master开启binlog日志，并创建主从用户replicater
> 

```shell
ansible-playbook mariadb.yml
```

- 需手动执行以下以开启主从
```sql
-- primary执行
show master status;
    
-- secondary执行
change master to MASTER_HOST='xxx',MASTER_PORT=3306,MASTER_USER='replicater',MASTER_PASSWORD='{{ mariadb_replicater_password }}',MASTER_LOG_FILE='xxx',MASTER_LOG_POS=xxx;

start slave;


```