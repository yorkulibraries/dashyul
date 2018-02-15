#!/usr/bin/env bash

# If no file is specified, it will use the most recent one in /sirsilogs/.
#
# To specify a file, give its full path as an argument:
#
# $ make-detailed-transactions.sh /sirsilogs/201608.hist.Z
#
# This script depends on the logs being named YYYYMM.hist.Z

# Get the Oracle environment variables.
source ~/.bash.orez.rc

SYMPHONY_DATA=${DASHYUL_DATA}/symphony
SYMPHONY_SCRIPTS=${DASHYUL_HOME}/sources/symphony/scripts

SYMPHONY_LOG_FULL_PATH=$1

if [ -z $SYMPHONY_LOG_FULL_PATH ]
then
    SYMPHONY_LOG_FULL_PATH=`ls -rt /sirsilogs/20*.hist.Z | tail -1`
fi

YYYYMM=`basename -s .hist.Z $SYMPHONY_LOG_FULL_PATH`
TRANSACTIONS=$YYYYMM-transactions.csv

echo "Month: $YYYYMM"

echo "Stage 1: transactions: parsing raw log file ... "
gunzip -c $SYMPHONY_LOG_FULL_PATH | ${SYMPHONY_SCRIPTS}/parse-monthly-transaction-logs.rb > ${SYMPHONY_DATA}/transactions/$TRANSACTIONS

echo "Stage 2: users: making user list ..."
${SYMPHONY_SCRIPTS}/make-detailed-transactions-stage-2.R ${SYMPHONY_DATA}/transactions/$TRANSACTIONS ${SYMPHONY_DATA}/users/user-information.csv > /tmp/tmp-$YYYYMM-1.csv

echo "Stage 3: users: getting student information from SIS ... "
# /data/users/scripts/get-student-information.rb /tmp/tmp-$YYYYMM-1.csv > /tmp/tmp-$YYYYMM-2.csv

echo "Stage 4: users: saving detailed user list ..."
${SYMPHONY_SCRIPTS}/make-detailed-transactions-stage-4.R /tmp/tmp-$YYYYMM-1.csv /tmp/tmp-$YYYYMM-2.csv > ${SYMPHONY_DATA}/transactions/$YYYYMM-users.csv

echo "Stage 5: items: saving item information ..."
${SYMPHONY_SCRIPTS}/make-detailed-transactions-stage-5.R ${SYMPHONY_DATA}/transactions/$TRANSACTIONS ${SYMPHONY_DATA}/catalogue/catalogue-current-item-details.csv > ${SYMPHONY_DATA}/transactions/$YYYYMM-items.csv

echo "Stage 6: records: saving record information ..."
${SYMPHONY_SCRIPTS}/make-detailed-transactions-stage-6.R ${SYMPHONY_DATA}/transactions/$YYYYMM-items.csv ${SYMPHONY_DATA}/catalogue/catalogue-current-title-metadata.csv > ${SYMPHONY_DATA}/transactions/$YYYYMM-records.csv

rm /tmp/tmp-$YYYYMM-1.csv
rm /tmp/tmp-$YYYYMM-2.csv

echo "Finished: `date`"
