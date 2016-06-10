#!/bin/bash

set -e
umask 007

DIR=$(pwd)

if [ ! -w "${DIR}" ]; then
	echo "The current directory is not writable!"
	exit 1
fi

VALID_AUTH=false

function CollectData {
	while true; do
		echo -n "MySQL host: "
		read MYSQL_HOST

		if [ ! -z "${MYSQL_HOST}" ]; then
			break
		fi
	done

	while true; do
		echo -n "MySQL user: "
		read MYSQL_USER

		if [ ! -z "${MYSQL_USER}" ]; then
			break
		fi
	done

	echo -n "MySQL pass: "
	read -s MYSQL_PASS
	echo ""

	DATABASES=$(MYSQL_PWD=${MYSQL_PASS} mysql --host ${MYSQL_HOST} --user ${MYSQL_USER} --batch --skip-column-names --execute="SHOW DATABASES" | grep -v performance_schema | grep -v information_schema | grep -v mysql 2>&1)

	if [ ! -z "$(echo $DATABASES)" ]; then
		VALID_AUTH=true
	fi
}

echo -n "Do you want to gzip the export [Y/n]: "
read GZ
if [ -z $GZ ] || [ $GZ = 'y' ] || [ $GZ = 'Y' ]; then
	GZIP=true
else
	GZIP=false
fi

while true; do
	if $VALID_AUTH; then
		break
	else
		CollectData
	fi
done

function preloader {
	echo ""

	while true; do
		printf '\033[K   Exporting...\r'
		sleep .5
		printf '\033[K   Exporting\r'
		sleep .5
		printf '\033[K   Exporting.\r'
		sleep .5
		printf '\033[K   Exporting..\r'
		sleep .5
	done

	echo ""
}

preloader &
preloader_pid=$!
disown

for db in $DATABASES; do
	if $GZIP; then
		MYSQL_PWD=${MYSQL_PASS} mysqldump \
			--host ${MYSQL_HOST} \
			--user ${MYSQL_USER} \
			--single-transaction \
			--quick \
			--skip-comments \
			--extended-insert \
			--routines \
			--triggers \
			--databases $db | gzip > $DIR/mysql_$db.sql.gz
	else
		MYSQL_PWD=${MYSQL_PASS} mysqldump \
			--host ${MYSQL_HOST} \
			--user ${MYSQL_USER} \
			--single-transaction \
			--quick \
			--skip-comments \
			--extended-insert \
			--routines \
			--triggers \
			--databases $db > $DIR/mysql_$db.sql
	fi
done

kill $preloader_pid

echo ""
echo ""
echo -e "\033[00;32mExport is complete\033[00m"
echo ""
echo "To import database use the following command:"
echo ""
if $GZIP; then
	echo -e "\033[00;33mzcat database.sql.gz | mysql -u user -p\033[00m"
else
	echo -e "\033[00;33mcat database.sql | mysql -u user -p\033[00m"
fi
echo ""
