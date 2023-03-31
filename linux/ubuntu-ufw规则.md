# 开启防火墙
ufw enable
# 允许80和443
ufw allow http
ufw allow https
# 允许某个ip
ufw allow from 192.168.3.212
ufw allow from 192.168.3.213
ufw allow from 192.168.3.214
ufw allow from 192.168.3.215
ufw allow from 192.168.3.216
ufw allow from 192.168.3.217
ufw allow from 192.168.3.218
ufw allow from 192.168.3.219
# 允许网段
ufw allow from 100.64.0.0/16 to 100.65.0.0/16
# 允许端口
ufw allow from 192.168.3.219 to 192.168.3.218 port 3306 proto tcp
ufw allow from 192.168.3.219 to 192.168.3.219 port 3306 proto tcp
