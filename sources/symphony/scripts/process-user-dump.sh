#!/bin/bash

echo "------"
echo "Started: `date`"

SYMPHONY_SCRIPTS=${DASHYUL_HOME}/sources/symphony/scripts
SYMPHONY_USER_DATA=${DASHYUL_DATA}/symphony/users

# Path to the raw, ugly Symphony dump of user information.
USER_DUMP_FULL_PATH=$1

if [ -z $USER_DUMP_FULL_PATH ]
then
    USER_DUMP_FULL_PATH=`ls -rt /sirsilogs/barcode.sysid.profile.affil.out* | tail -1`
fi

YYYYMMDD=`echo $USER_DUMP_FULL_PATH | sed 's/.*out-//'`

${SYMPHONY_SCRIPTS}/convert-symphony-user-dump.rb $USER_DUMP_FULL_PATH > ${SYMPHONY_USER_DATA}/user-information-$YYYYMMDD.csv
rm -f ${SYMPHONY_USER_DATA}/user-information.csv
ln -s ${SYMPHONY_USER_DATA}/user-information-$YYYYMMDD.csv ${SYMPHONY_USER_DATA}/user-information.csv

echo "Finished: `date`"
