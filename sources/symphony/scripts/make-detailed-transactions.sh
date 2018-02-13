#!/usr/bin/env bash
# If no file is specified, it will use the most recent one in /sirsilogs/.
#
# To specify a file, give its full path as an argument:
#
# $ make-detailed-transactions.sh /sirsilogs/201608.hist.Z
#
# This script depends on the logs being named YYYYMM.hist.Z

# Get the Oracle environment variables.
source ~/.bash.vm1.rc

# Run the Ruby under RVM
# TODO: Use proper system-wide Ruby.
RVM_PATH=`~/.rvm/bin/rvm env --path -- ruby-version[@gemset-name]`
source $RVM_PATH

cd /data/symphony

SYMPHONY_LOG_FULL_PATH=$1

if [ -z $SYMPHONY_LOG_FULL_PATH ]
then
  SYMPHONY_LOG_FULL_PATH=`ls -rt /sirsilogs/20*.hist.Z | tail -1`
fi

YYYYMM=`basename -s .hist.Z $SYMPHONY_LOG_FULL_PATH`
TRANSACTIONS=$YYYYMM-transactions.csv

echo "Month: $YYYYMM"

echo "Stage 1: transactions: parsing raw log file ... "
gunzip -c $SYMPHONY_LOG_FULL_PATH | scripts/parse-monthly-transaction-logs.rb > data/transactions/$TRANSACTIONS

echo "Stage 2: users: making user list ..."
scripts/make-detailed-transactions-stage-2.R data/transactions/$TRANSACTIONS /data/users/user-information.csv > tmp-$YYYYMM-1.csv

echo "Stage 3: users: getting student information from SIS ... "
/data/users/scripts/get-student-information.rb tmp-$YYYYMM-1.csv > tmp-$YYYYMM-2.csv

echo "Stage 4: users: saving detailed user list ..."
scripts/make-detailed-transactions-stage-4.R tmp-$YYYYMM-1.csv tmp-$YYYYMM-2.csv > data/transactions/$YYYYMM-users.csv

echo "Stage 5: items: saving item information ..."
scripts/make-detailed-transactions-stage-5.R data/transactions/$TRANSACTIONS data/catalogue/catalogue-current-item-details.csv > data/transactions/$YYYYMM-items.csv

echo "Stage 6: records: saving record information ..."
scripts/make-detailed-transactions-stage-6.R data/transactions/$YYYYMM-items.csv data/catalogue/catalogue-current-title-metadata.csv > data/transactions/$YYYYMM-records.csv

rm tmp-$YYYYMM-1.csv
rm tmp-$YYYYMM-2.csv

echo "Finished: `date`"
