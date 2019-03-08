#!/bin/bash
 
################################################################
 
export PATH=/bin:/usr/bin:/usr/local/bin:/usr/sbin/
TODAY=`date +"%d-%m-%Y"`

################################################################
################## Update below values  ########################
 
DB_BACKUP_PATH='/backup/dbbackup'
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USER='backup'
MYSQL_PASSWORD='passwd'
#DATABASES=("cabinet" "admin" "site")
for DATABASE_NAME in "cabinet" "admin" "site"
do
BACKUP_RETAIN_DAYS=31   ## Number of days to keep local backup copy

#################################################################
 
mkdir -p ${DB_BACKUP_PATH}/${TODAY}
echo "Backup started for database - ${DATABASE_NAME}"
 
 
mysqldump --single-transaction -h ${MYSQL_HOST} \
   -P ${MYSQL_PORT} \
   -u ${MYSQL_USER} \
   -p${MYSQL_PASSWORD} \
   ${DATABASE_NAME} | gzip > ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}.sql.gz
 
if [ $? -eq 0 ]; then
  echo "Database backup successfully completed"
else
  echo "Error found during backup"
fi
 
 
##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####
 
DBDELDATE=`date +"%d%b%Y" --date="${BACKUP_RETAIN_DAYS} days ago"`
 
if [ ! -z ${DB_BACKUP_PATH} ]; then
      cd ${DB_BACKUP_PATH}
      if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
            rm -rf ${DBDELDATE}
      fi
fi
done
############# Add information about db backup directory 

ls -la ${DB_BACKUP_PATH}/${TODAY}/ > ${DB_BACKUP_PATH}/backupdirstatus


##########################################################################
###      Enable Email Alerts
##########################################################################

#SENDEMAIL= ( 0 for not to send email, 1 for send email )
SENDEMAIL=1
EMAILTO='mr.danielyan55@yahoo.com'


if [ $SENDEMAIL -eq 1 ]
  then
     sendmail -t ${EMAILTO} < $PWD/dbmail ${DB_BACKUP_PATH}/backupdirstatus
  fi


### End of script ####

