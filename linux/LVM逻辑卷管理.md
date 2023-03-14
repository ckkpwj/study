1 查看
```shell
fdisk -l
```
2 分区
```shell
fdisk /dev/sdb
```
3 创建PV
```shell
pvcreate /dev/sdb1
```
4 创建VG
```shell
vgcreate ubuntu /dev/sdb1
```
5 创建LV
```shell
lvcreate -n lv-ubuntu  -l  100%FREE  ubuntu
```
6 创建文件系统并挂载
```shell
mkfs.xfs /dev/mapper/ubuntu-lv--ubuntu

mkdir -p /data/kubenetes
```
7 加入/etc/fstab文件：
```shell
/dev/mapper/ubuntu-lv--ubuntu /data/kubenetes xfs defaults 0 0
```
8 挂载
```shell
mount -a
```
