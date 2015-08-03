#!/bin/bash

umask 007

DIR=$(pwd)

if [ ! -w "${DIR}" ]; then
	echo "The current directory is not writable!"
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
	MYSQL_PWD=${MYSQL_PASS} mysqldump --host ${MYSQL_HOST} --user ${MYSQL_USER} --single-transaction --quick --skip-comments --extended-insert --databases $db | gzip > $DIR/mysql_$db.sql.gz
done

kill $preloader_pid

echo ""
echo ""
echo -e "\033[00;32mExport is complete\033[00m"
echo ""
echo "To import database use the following command:"
echo ""
echo -e "\033[00;33mzcat database.sql.gz | mysql -u user -p\033[00m"
echo ""