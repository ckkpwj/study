#查看firewall状态，LINUX7默认是安装并开启的；
firewall-cmd --state
#安装
yum install firewalld
#启动,
systemctl start firewalld
#设置开机启动
systemctl enable firewalld
#关闭
systemctl stop firewalld
#取消开机启动
systemctl disable firewalld

#禁止IP(123.44.55.66)访问机器
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address="123.44.55.66" drop'
#禁止一个IP段，比如禁止116.255.*.*
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address="116.255.0.0/16" drop'
#禁止一个IP段，比如禁止116.255.196.*
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address="116.255.196.0/24" drop'

#禁止机器IP(123.44.55.66)从防火墙中删除
firewall-cmd --permanent --remove-rich-rule='rule family=ipv4 source address="123.44.55.66" drop'

#允许http服务(对应服务策略目录：/usr/lib/firewalld/services/)
firewall-cmd --permanent --add-service=http
#关闭http服务(对应服务策略目录：/usr/lib/firewalld/services/)
firewall-cmd --permanent --remove-service=http

#允许端口:3389
firewall-cmd --permanent --add-port=3389/tcp
#允许端口:1-3389
firewall-cmd --permanent --add-port=1-3389/tcp
#关闭放行中端口:3389
firewall-cmd --permanent --remove-port=3389/tcp

#查看firewall的状态
firewall-cmd --state
#查看防火墙规则（只显示/etc/firewalld/zones/public.xml中防火墙策略，在配置策略前，我一般喜欢先CP，以后方便直接还原）
firewall-cmd --list-all
#查看所有的防火墙策略（即显示/etc/firewalld/zones/下的所有策略）
firewall-cmd --list-all-zones
#重新加载配置文件
firewall-cmd --reload

#更改配置后一定要重新加载配置文件：
firewall-cmd --reload