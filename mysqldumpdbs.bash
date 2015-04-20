#!/bin/bash

umask 007

DIR=$(pwd)

if [ ! -w "${DIR}" ]; then
	echo "The current directory is not writable!"
fi

VALID_AUTH=false

function CollectData {
	while true; do
		echo -n "MySQL user: "
		read MYSQL_USER

		if [ ! -z "${MYSQL_USER}" ]; then
			break
		fi
	done

	while true; do
		echo -n "MySQL password: "
		read -s MYSQL_PASS
		echo ""

		if [ ! -z "${MYSQL_PASS}" ]; then
			break
		fi
	done

	DATABASES=$(MYSQL_PWD=${MYSQL_PASS} mysql --user ${MYSQL_USER} --batch --skip-column-names --execute="SHOW DATABASES" | grep -v performance_schema | grep -v information_schema | grep -v mysql 2>&1)

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

for db in $DATABASES; do
	MYSQL_PWD=${MYSQL_PASS} mysqldump --user ${MYSQL_USER} --single-transaction --quick --skip-comments --compact --extended-insert --databases $db | gzip > $DIR/mysql_$db.sql.gz
done