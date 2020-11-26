#!/bin/sh


#TODO: Be bothered to actually fix this.
exit 0

: ${DATABASE_HOST:?"Need to set DATABASE_HOST"}
: ${DATABASE_PORT:?"Need to set DATABASE_PORT"}
: ${DATABASE_USERNAME:?"Need to set DATABASE_USERNAME"}
: ${DATABASE_PASSWORD:?"Need to set DATABASE_PASSWORD"}
: ${DATA_FOLDER:?"Need to set DATA_FOLDER"}
: ${BACKUP_FOLDER:?"Need to set BACKUP_FOLDER"}
: ${BACKUP_RETENTION:?"Need to set BACKUP_RETENTION"}

mkdir -p $BACKUP_FOLDER/data
mkdir -p $BACKUP_FOLDER/backups

TODAY=$(date +"%Y-%m-%d")
echo "Running Backup for $TODAY"

echo "Copying data to backup (Skipping Existing or Unchanged files)"
cp -ru $DATA_FOLDER $BACKUP_FOLDER/data

echo "Creating temporary folder for Database & etcd dump."
TMP_DIR=$(mktemp -d)
echo "Temp dir created: $TMP_DIR"

echo "Dump MariaDB databases to data.sql file."
mariadb-dump --all-databases -h $DATABASE_HOST -P $DATABASE_PORT -u $DATABASE_USERNAME -p $DATABASE_PASSWORD > $TMP_DIR/data.sql

# TODO: etcd dump

echo "Compress dumped data into zip archive."
zip -r $BACKUP_FOLDER/backups/backup-$TODAY.zip $TMP_DIR

echo "Delete temp folder"
rm -rf $TMP_DIR

echo "Delete backups older than $BACKUP_RETENTION days"
find $BACKUP_FOLDER/backups -type f -mtime +$BACKUP_RETENTION -name '*.zip' -execdir rm -- '{}' \;
