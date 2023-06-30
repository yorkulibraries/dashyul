#!/bin/bash

cd $DASHYUL_DATA/alma/transactions/ || exit

yyyymmdd=$(ls transactions-????????.csv | sort | tail -1 | sed 's/transactions-//' | sed 's/.csv//')

echo "Making detailed transactions for $yyyymmdd ..."

$DASHYUL_HOME/sources/alma/scripts/make-detailed-transactions.R --yyyymmdd $yyyymmdd

rm -f detailed-transactions-current.csv
rm -f detailed-transactions-current.rds

ln -s detailed-transactions-${yyyymmdd}.csv detailed-transactions-current.csv
ln -s detailed-transactions-${yyyymmdd}.rds detailed-transactions-current.rds
