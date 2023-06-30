#!/bin/bash

cd $DASHYUL_DATA/alma/transactions/ || exit
report_number=$(find . -type f -name 'Trans*Report_*' | sort | tail -1 | sed 's/.*Report_//' | sed 's/.csv//')

yyyymmdd=${report_number:0:8}

echo "Extracting from $report_number ($yyyymmdd) ..."

$DASHYUL_HOME/sources/alma/scripts/extract-alma-transaction-data.R --id $report_number

rm -f transactions-current.csv
rm -f transactions-current.rds

ln -s transactions-${yyyymmdd}.csv transactions-current.csv
ln -s transactions-${yyyymmdd}.rds transactions-current.rds
