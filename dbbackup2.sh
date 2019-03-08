#!/bin/bash

# "Приветствие"
echo "+=======================+"
echo "| DB Backuping started! |"
echo "+-----------------------+"

# Задаем настройки для бекапинга
DB_USER="root"
DB_PASS="thzDnriYJjJ0HH2M"
DB_NAME=$1 # имя базы передаем в параметре
DATABASES=("$DB_NAME")
BACKUP_DIR='/var/backups/db'

# Очищаем старые бекапы
echo "Cleaning old backups..."
find "$BACKUP_DIR" -mtime +31 -print -mindepth 1 -delete >/dev/null 2>&1 #делаем авто очистку мусора, который старше 31 дней.

# проходим по массиву с именами баз данных, которые нужно забекапить
#DATE=`date +%F` #префикс c датой, чтобы знать от какого числа бэкап
DATE=`date +"%F %H-%M"`
for (( i = 0 ; i < ${#DATABASES[@]} ; i++ ))
do
    DB_NAME="${DATABASES[$i]}"
    BACKUP_FN="$DB_NAME.$DATE.sql"
    BACKUP_FULL_FN="$BACKUP_DIR/$DB_NAME.$DATE.sql" #указываем директорию и название файла, куда будет писаться дамп
    DBGZIP="$BACKUP_DIR/$DB_NAME.$DATE.tar.gz" #указываем директорию и название архива, куда будет писаться дамп

    echo "Backing up database \"$DB_NAME\"..."
    mysqldump -u$DB_USER -h localhost -p$DB_PASS $DB_NAME > "$BACKUP_FULL_FN" #указываем какую базу вам нужно бэкапить
    echo "Archiving fresh backup file..."
    cd "$BACKUP_DIR"
    tar czfP "$DBGZIP" "$BACKUP_FN" #архивируем полученный бэкап
    rm "$BACKUP_FULL_FN" #удаляем .sql, который заархивировали
done

echo "Done!"
