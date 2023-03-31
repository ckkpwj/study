```shell

[root@wscyun ~]# parted /dev/sdb    #进入parted命令交互后并使用/dev/sdb硬盘
GNU Parted 3.1
使用 /dev/sdb
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) mklabel gpt    # 设置格式类型为gpt                                                  
(parted) mkpart p1 1 500G   #创建p1分区                                              
(parted) mkpart p2 500G 1500G    #创建p2分区
(parted) mkpart p3 1500G -1    #创建p3分区,使用剩余空间                                 
(parted) print     #打印查看分区                                                       
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdb: 4398GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name  标志
1      1049kB  500GB   500GB                p1
2      500GB   1500GB  1000GB               p2
3      1500GB  4398GB  2898GB               p3

(parted) quit     #退出工具                                                        
信息: You may need to update /etc/fstab.

```