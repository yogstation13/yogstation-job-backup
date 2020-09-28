#!/bin/sh

: ${DATABASE_HOST:?"Need to set DATABASE_HOST"}
: ${DATABASE_PORT:?"Need to set DATABASE_PORT"}
: ${DATABASE_USERNAME:?"Need to set DATABASE_USERNAME"}
: ${DATABASE_PASSWORD:?"Need to set DATABASE_PASSWORD"}
: ${BACKUP_RETENTION:?"Need to set BACKUP_RETENTION"}

TODAY=$(date +"%Y-%m-%d")

echo "Running Backup for ${TODAY}"

echo "Copying data to backup (Skipping Existing or Unchanged files)"
cp -ru /data /backup/data

echo "Creating temporary folder for Database & etcd dump."
mkdir /backup_temp

echo "Dump MariaDB databases to data.sql file."
mariadb-dump --all-databases -h $DATABASE_HOST -P $DATABASE_PORT -u $DATABASE_USERNAME -p $DATABASE_PASSWORD > /backup_temp/data.sql 

echo "Compress dumped data into zip archive."
zip -r /backup/backups/backup-${TODAY}.zip /backup_temp

echo "Delete temp folder"
rm -r /backup_temp

echo "Delete backups older than ${BACKUP_RETENTION} days"
find /backup/backups -type f -mtime +${BACKUP_RETENTION} -name '*.zip' -execdir rm -- '{}' \;