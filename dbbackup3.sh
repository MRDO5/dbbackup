#!/bin/bash

DATE=`date +%Y-%M-%d`
YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`
HOURS=`date +%H`
MINUTES=`date +%M`
DBUSER="root"
DBPASS="thzDnriYJjJ0HH2M"
DBHOST="localhost"

mysql -h $DBHOST -u $DBUSER -p$DBPASS -e "show databases;" > /tmp/databases.list

BACKUP_DIR=/home/backups/mysql/$YEAR/$MONTH/$DAY/$HOURS-$MINUTES

mkdir --parents --verbose $BACKUP_DIR
EXCLUDES=('Database' 'information_schema')
NUM_EXCLUDES=${#EXCLUDES[@]}

for database in `cat /tmp/databases.list`;
    do
       skip=0 let count=0
     while [ $count -lt $NUM_EXCLUDES ] ;
    do
      if [ "$database" = ${EXCLUDES[$count]} ] ; 
        then let skip=1
      fi
        let count=$count+1
      done
      if [[ $skip -eq 0 ]] ;
        then  echo "++ $database"
cd $BACKUP_DIR
backup_name="$YEAR-$MONTH-$DAY.$HOURS-$MINUTES.$database.backup.sql"
backup_tarball_name="$backup_name.tar.gz"
/usr/bin/mysqldump -h "$DBHOST" --routines --databases "$database" -u "$DBUSER" --password="$DBPASS" > "$backup_name" echo "backup $backup_name"
/bin/tar -cfz "$backup_tarball_name" "$backup_name"
echo "compress $backup_tarball_name"
#/bin/rm "$backup_name"
echo "cleanup $backup_name"
      fi
      done
/bin/rm /tmp/databases.list
echo "done!"

