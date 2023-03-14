#!/bin/bash

DATE=$(date +%F-%H%M)

if [ "$(lsb_release -cs)" == 'jammy' ];then
  mv /etc/apt/sources.list /etc/apt/sources.list."${DATE}".bak
  echo 'deb https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse' > /etc/apt/sources.list
  apt -y update
  apt -y install software-properties-common git ansible sshpass
elif [ "$(lsb_release -cs)" == 'focal' ];then
  mv /etc/apt/sources.list /etc/apt/sources.list."${DATE}".bak
  echo 'deb https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse' > /etc/apt/sources.list
  apt -y update
  apt -y install software-properties-common git ansible sshpass
else
  echo '[Base]
name=aliBase
baseurl=https://mirrors.aliyun.com/centos/$releasever/os/$basearch/
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos/$releasever/os/$basearch/RPM-GPG-KEY-CentOS-$releasever

[aliEpel]
name=aliEpel
baseurl=https://mirrors.aliyun.com/epel/$releasever\Server/$basearch/
enabled=1
gpgcheck=0' > /etc/yum.repos.d/aliBase.repo
  yum makecache
  yum -y install ansible epel-release git
fi

