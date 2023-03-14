#!/bin/bash

# 修改内核参数
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

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
modprobe br_netfilter
sysctl -p /etc/sysctl.d/k8s.conf

# 开启IPVS
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4

