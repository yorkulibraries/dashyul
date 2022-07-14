#!/bin/sh

cd $DASHYUL_DATA/alma/transactions/
report_number=$(ls Trans*Report_* | tail -1 | sed 's/.*Report_//' | sed 's/.csv//')

echo "Extracting from $report_number ..."

$DASHYUL_HOME/sources/alma/scripts/extract-alma-transaction-details.R --id $report_number
