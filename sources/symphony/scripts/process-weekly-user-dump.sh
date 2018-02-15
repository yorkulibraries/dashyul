#!/bin/bash

SYMPHONY_SCRIPTS=${DASHYUL_HOME}/sources/symphony/scripts
SYMPHONY_DATA=${DASHYUL_DATA}/symphony

# Path to the raw, ugly Symphony dump of user information.
USER_DUMP_FULL_PATH=$1

if [ -z $USER_DUMP_FULL_PATH ]
then
    USER_DUMP_FULL_PATH=`ls -rt /sirsilogs/barcode.sysid.profile.affil.out* | tail -1`
fi

YYYYMMDD=`echo $USER_DUMP_FULL_PATH | sed 's/.*out-//'`

${SYMPHONY_SCRIPTS}/convert-symphony-user-dump.rb $USER_DUMP_FULL_PATH > ${SYMPHONY_DATA}/user-information-$YYYYMMDD.csv
rm -f ${SYMPHONY_DATA}/user-information.csv
ln -s ${SYMPHONY_DATA}/user-information-$YYYYMMDD.csv ${SYMPHONY_DATA}/user-information.csv
