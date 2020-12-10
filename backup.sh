#!/bin/sh

: ${DATABASE_HOST:?"Need to set DATABASE_HOST"}
: ${DATABASE_PORT:?"Need to set DATABASE_PORT"}
: ${DATABASE_USERNAME:?"Need to set DATABASE_USERNAME"}
: ${DATABASE_PASSWORD:?"Need to set DATABASE_PASSWORD"}
: ${LOGS_FOLDER:?"Need to set LOGS_FOLDER"}
: ${BACKUP_FOLDER:?"Need to set BACKUP_FOLDER"}

: ${BACKUP_RETENTION:=7}
: ${DEMO_RETENTION:=180}

mkdir -p $BACKUP_FOLDER/data
mkdir -p $BACKUP_FOLDER/backups

TODAY=$(date +"%Y-%m-%d")
echo "Running Backup for $TODAY"

echo "Copying logs older than a day to backup (Skipping Existing files)"
cd $LOGS_FOLDER
find . -mtime +1 -exec rsync --ignore-existing -Rq '{}' $BACKUP_FOLDER/logs \;

echo "Creating temporary folder for Database & etcd dump."
TMP_DIR=$(mktemp -d)
echo "Temp dir created: $TMP_DIR"

echo "Dump MariaDB databases to data.sql file."
mariadb-dump --all-databases -h $DATABASE_HOST -P $DATABASE_PORT -u $DATABASE_USERNAME -p $DATABASE_PASSWORD > $TMP_DIR/data.sql

# TODO: etcd dump

echo "Compress dumped data into zip archive."
zip -r $BACKUP_FOLDER/backups/backup-$TODAY.zip $TMP_DIR

echo "Delete temp folder"
rm -r $TMP_DIR

echo "Delete backups older than $BACKUP_RETENTION days."
find $BACKUP_FOLDER/backups -type f -mtime +$BACKUP_RETENTION -name '*.zip' -execdir rm -- '{}' \;

# echo "Delete demos older than $DEMO_RETENTION days."
# find $LOGS_FOLDER -mtime +180 -name demo.txt.gz 