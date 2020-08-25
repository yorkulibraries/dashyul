#!/bin/bash

SIS_DATA=${DASHYUL_DATA}/sis

SIS_SCRIPTS=${DASHYUL_HOME}/sources/sis/scripts

YYYYMMDD=`date +%Y%m%d`

echo "------"
echo "Started: `date`"

cd ${SIS_DATA}

${SIS_SCRIPTS}/get-list-of-all-students.rb > all-students-${YYYYMMDD}.csv
rm all-students.csv
ln -s all-students-${YYYYMMDD}.csv all-students.csv

echo "Finished: `date`"
