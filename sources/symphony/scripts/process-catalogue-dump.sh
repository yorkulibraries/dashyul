#!/usr/bin/env bash

# Turn the huge monthly catalogue MARC dump into more usable files.

echo "------"
echo "Started: $(date)"

SYMPHONY_SCRIPTS=${DASHYUL_HOME}/sources/symphony/scripts
SYMPHONY_CATALOGUE_DATA=${DASHYUL_DATA}/symphony/catalogue

MARC_DUMP=$1
if [ -z "$MARC_DUMP" ]
then
    MARC_DUMP=$(ls -rt /sirsilogs/catalogue*mrc | tail -1)
fi
DUMP_FILE=$(basename -s .mrc "$MARC_DUMP")

cd ${SYMPHONY_CATALOGUE_DATA}

echo -n "$DUMP_FILE:  item details (~ 25 mins) ... "
${SYMPHONY_SCRIPTS}/extract-catalogue-item-details.rb $MARC_DUMP > ${DUMP_FILE}-item-details.csv
${SYMPHONY_SCRIPTS}/extract-catalogue-item-details.R --dump-file ${DUMP_FILE}

echo -n "title metadata ... (~ 20 mins) ... "
${SYMPHONY_SCRIPTS}/extract-catalogue-title-metadata.rb $MARC_DUMP > ${DUMP_FILE}-title-metadata.csv

echo -n "to text ... (~ 1 mins) "
yaz-marcdump "$MARC_DUMP" > "${DUMP_FILE}.txt"

echo -n "linking ..."
rm -f catalogue-current-item-details.csv
rm -f catalogue-current-item-details.rds
rm -f catalogue-current-title-metadata.csv
ln -s ${DUMP_FILE}-item-details.csv catalogue-current-item-details.csv
ln -s ${DUMP_FILE}-item-details.rds catalogue-current-item-details.rds
ln -s ${DUMP_FILE}-title-metadata.csv catalogue-current-title-metadata.csv

echo "Finished: $(date)"
