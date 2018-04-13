#!/usr/bin/env bash

# From the huge monthly catalogue dump, pull out the ISBNs and item
# numbers.

echo "------"
echo "Started: `date`"

SYMPHONY_SCRIPTS=${DASHYUL_HOME}/sources/symphony/scripts
SYMPHONY_CATALOGUE_DATA=${DASHYUL_DATA}/symphony/catalogue

MARC_DUMP=$1
if [ -z $MARC_DUMP ]
then
    MARC_DUMP=`ls -rt /sirsilogs/catalogue*mrc | tail -1`
fi
DUMP_FILE=`basename -s .mrc $MARC_DUMP`

cd ${SYMPHONY_CATALOGUE_DATA}

echo "$DUMP_FILE: extracting ..."

${SYMPHONY_SCRIPTS}/extract-catalogue-isbn-item-number-map.rb $MARC_DUMP > ${DUMP_FILE}-isbn-item-number.csv

echo -n "linking ..."
rm -f catalogue-current-isbn-item-number.csv
ln -s ${DUMP_FILE}-isbn-item-number.csv catalogue-current-isbn-item-number.csv

echo "Finished: `date`"
