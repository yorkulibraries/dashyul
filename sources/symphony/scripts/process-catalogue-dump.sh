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

# PREFIX will be catalogue-20180630 or some other YYYYMMDD.
PREFIX=$(basename -s .mrc "$MARC_DUMP")

cd ${SYMPHONY_CATALOGUE_DATA}

echo -n "$PREFIX:  item details (~ 25 mins) ... "
${SYMPHONY_SCRIPTS}/extract-catalogue-item-details.rb $MARC_DUMP > ${PREFIX}-item-details.csv
${SYMPHONY_SCRIPTS}/extract-catalogue-item-details.R --prefix ${PREFIX}

echo -n "title metadata ... (~ 20 mins) ... "
${SYMPHONY_SCRIPTS}/extract-catalogue-title-metadata.rb $MARC_DUMP > ${PREFIX}-title-metadata.csv
${SYMPHONY_SCRIPTS}/extract-catalogue-title-metadata.R --prefix ${PREFIX}

echo -n "numbers ... (~ 20 mins) ... "
${SYMPHONY_SCRIPTS}/extract-catalogue-number-map.rb $MARC_DUMP > ${PREFIX}-number-mapping.csv
${SYMPHONY_SCRIPTS}/extract-catalogue-number-map.R --prefix ${PREFIX}

echo -n "856s ... (~ 20 mins) "
${SYMPHONY_SCRIPTS}/extract-catalogue-856.rb $MARC_DUMP > ${PREFIX}-856.csv
${SYMPHONY_SCRIPTS}/extract-catalogue-856.R --prefix ${PREFIX}

echo -n "to text ... (~ 1 mins) "
yaz-marcdump "$MARC_DUMP" > "${PREFIX}.txt"

echo -n "linking ..."
FILENAME_PIECES="item-details title-metadata number-mapping 856"
for PIECE in $FILENAME_PIECES
do
    rm -f catalogue-current-${PIECE}.{csv,rds}
    ln -s ${PREFIX}-${PIECE}.csv catalogue-current-${PIECE}.csv
    ln -s ${PREFIX}-${PIECE}.rds catalogue-current-${PIECE}.rds
done

echo "Finished: $(date)"
