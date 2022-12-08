
WORKDIR=/data/logs
DATE=$(date +%F)

MainProcess (){
  for DIRS in $(ls $WORKDIR)
  do
    [ -d $WORKDIR/$DIRS ] || continue
    cd $WORKDIR/$DIRS
    ls *.log &> /dev/null
    if [ $? -eq 0 ];then
      for FILES in $(ls *.log|egrep '[0-9]{4}-[0-9]{2}-[0-9]{2}'|grep -v "$(date +%Y-%m-%d)")
      do
        gzip $FILES
      done

      for FILES in $(ls *.txt|egrep '[0-9]{4}-[0-9]{2}-[0-9]{2}'|grep -v "$(date +%Y-%m-%d)")
      do
        gzip $FILES
      done
      find . -type f -mtime +30 -name "*.gz" -exec rm -f {} \;
    fi
  done
}


MainProcess
