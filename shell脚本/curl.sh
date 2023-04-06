#!/bin/bash
URL="http://bsdt.cumt.edu.cn/"
HTTP_CODE=`curl -o /dev/null -s -w "%{http_code}" "${URL}"`

set i=0
set j=0
for ((i=0;i<10;))
do  
   DATE=`date '+%Y-%m-%d %H:%M:%S'`
   sleep 30
   let "j=j+1"
   if [ ${HTTP_CODE} -eq 302 ]
   then 
         echo "${DATE} 第${j}次curl ${URL}正常" >> /opt/bsdt.log
   else 
         echo "${DATE} 第${j}次curl ${URL}不正常" >> /opt/bsdt-error.log
   fi
   
done 



#!/bin/bash
set j=0
URL="http://gateway.jiangnan.edu.cn/casp-tdc/taskReceive/pushTask"
HTTP_CODE=`curl -o /dev/null -s -w "%{http_code}" "${URL}"`
for i in  $(kubectl get pod -nketanyun|grep Running|awk '/data-push-wis/{print $1}')
do
   DATE=`date '+%Y-%m-%d %H:%M:%S'`
   sleep 30
   let "j=j+1"
   kubectl exec  $i -nketanyun -- apk add curl 
   if [ ${HTTP_CODE} -eq 200 ]
   then 
         echo "${DATE} 第${j}次curl ${URL}正常" >> /opt/data-push.log
   else 
         kubectl -n ketanyun delete pod  $i
   fi
done
