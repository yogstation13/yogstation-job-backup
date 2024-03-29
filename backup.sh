#!/bin/sh

: ${DATABASE_HOST:?"Need to set DATABASE_HOST"}
: ${DATABASE_PORT:?"Need to set DATABASE_PORT"}
: ${DATABASE_USERNAME:?"Need to set DATABASE_USERNAME"}
: ${DATABASE_PASSWORD:?"Need to set DATABASE_PASSWORD"}
: ${LOGS_FOLDER:?"Need to set LOGS_FOLDER"}
: ${BACKUP_FOLDER:?"Need to set BACKUP_FOLDER"}

: ${BACKUP_RETENTION:=7}
: ${DEMO_RETENTION:=180}

mkdir -p $BACKUP_FOLDER/logs
mkdir -p $BACKUP_FOLDER/backups

TODAY=$(date +"%Y-%m-%d")
echo "Running Backup for $TODAY"

echo "Copying logs older than a day to backup (Skipping Existing files)"
cd $LOGS_FOLDER
find . -mtime +1 -exec rsync --ignore-existing -Rq '{}' $BACKUP_FOLDER/logs \;

echo "Creating temporary folder for Database & etcd dump."
TMP_DIR=/tmp/backup
mkdir $TMP_DIR
echo "Temp dir created: $TMP_DIR"

mkdir -p $TMP_DIR/db

echo "Dumping Forums DB to data.sql file."
mariadb-dump -h $DATABASE_HOST -P $DATABASE_PORT -u $DATABASE_USERNAME -p$DATABASE_PASSWORD yogstation_forums > $TMP_DIR/db/forums.sql

echo "Dumping Game DB to data.sql file."
mariadb-dump -h $DATABASE_HOST -P $DATABASE_PORT -u $DATABASE_USERNAME -p$DATABASE_PASSWORD yogstation_copy > $TMP_DIR/db/game.sql

echo "Dumping Wiki DB to data.sql file."
mariadb-dump -h $DATABASE_HOST -P $DATABASE_PORT -u $DATABASE_USERNAME -p$DATABASE_PASSWORD yogstation_wiki > $TMP_DIR/db/wiki.sql

# TODO: etcd dump

echo "Compress dumped data into zip archive."
zip -qr $BACKUP_FOLDER/backups/backup-$TODAY.zip $TMP_DIR

echo "Delete backups older than $BACKUP_RETENTION days."
find $BACKUP_FOLDER/backups -type f -mtime +$BACKUP_RETENTION -name '*.zip' -exec rm -- '{}' \;

echo "Delete demos older than $DEMO_RETENTION days."
#find . -mtime +$DEMO_RETENTION -name demo.txt.gz -exec rm {} \;
