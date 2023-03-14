#!/bin/bash

# 关闭自动更新
sed -i s/1/0/g /etc/apt/apt.conf.d/10periodic || true

# 关闭防火墙
ufw disable || true

# 修改limit参数
if ! grep 'soft nofile 655360' /etc/security/limits.conf &> /dev/null;then
  echo '* soft nofile 655360
* hard nofile 655360
root soft nofile 655360
root hard nofile 655360
* soft nproc 655360
* hard nproc 655360
* soft  memlock  unlimited
* hard memlock  unlimited' >> /etc/security/limits.conf
  echo 'DefaultLimitNOFILE=1024000
DefaultLimitNPROC=1024000' >> /etc/systemd/system.conf
fi

# 禁用swap分区
#if ! grep "vm.swappiness = 0"  /etc/sysctl.conf &> /dev/null;then
#  swapoff -a && echo "vm.swappiness = 0" >> /etc/sysctl.conf
#fi

#if grep "swap" /etc/fstab &> /dev/null;then
#  mv /etc/fstab /etc/fstab_bak
#  cat /etc/fstab_bak |grep -v swap > /etc/fstab
#fi

# 修改内核参数
if ! grep 'net.bridge.bridge-nf-call-ip6tables = 1' /etc/sysctl.d/k8s.conf &> /dev/null;then
  echo 'net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1' >> /etc/sysctl.d/k8s.conf
  modprobe br_netfilter
  sysctl -p /etc/sysctl.d/k8s.conf
  # 开启IPVS
  for i in $(ls /lib/modules/"$(uname -r)"/kernel/net/netfilter/ipvs|grep -o "^[^.]*");do
    echo "$i"; /sbin/modinfo -F filename "$i" >/dev/null 2>&1 && /sbin/modprobe "$i";
  done
  ls /lib/modules/"$(uname -r)"/kernel/net/netfilter/ipvs|grep -o "^[^.]*" >> /etc/modules
fi

