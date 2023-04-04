#!/bin/bash
DATE=$(date +%F)
BACKDIR=/data/mysqlbackup  #备份位置
mkdir -p ${BACKDIR}
#备份多个实例的配置
sun=sso
for i in ${sun[*]}; do
	   echo "start mysqldump ${i}"
	      mysqldump -uxxx  -p'xxx' --log-error=${BACKDIR}/`date +%F`.log --ignore-table=mysql.general_log --ignore-table=mysql.slow_log --lock-tables=0 ${i} > ${BACKDIR}/${DATE}-${i}.sql
	         echo "mysqldump ${i} ok "
	 done
	 find  ${BACKDIR} -type f -name "*.log" -mtime +7 |xargs rm -rf {}\;
	 find  ${BACKDIR} -type f -name "*.sql" -mtime +7 |xargs rm -rf {}\;
