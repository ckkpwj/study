#  ubuntu安装mariadb10.5
```shell
apt-get install apt-transport-https curl -y

curl -o /etc/apt/trusted.gpg.d/mariadb_release_signing_key.asc 'https://mariadb.org/mariadb_release_signing_key.asc'

sudo sh -c "echo 'deb https://mirrors.aliyun.com/mariadb/repo/10.5/ubuntu focal main' >>/etc/apt/sources.list"

apt-get update -y 
apt-get install mariadb-server -y
systemctl start mariadb
systemctl enable mariadb

```