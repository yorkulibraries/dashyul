#!/bin/bash

EZPROXY_LOG_FULL_PATH=$1

if [ -z $EZPROXY_LOG_FULL_PATH ]
then
    EZPROXY_LOG_FULL_PATH=`ls -rt /accesslogs/ezproxy.log-20* | tail -1`
fi

YYYYMMDD=`basename -s .gz $EZPROXY_LOG_FULL_PATH | sed 's/ezproxy.log-//'`

EZPROXY_SCRIPTS=${DASHYUL_HOME}/sources/ezproxy/scripts
EZPROXY_DATA=${DASHYUL_DATA}/ezproxy

SP_EBOOKS_SCRIPTS=${DASHYUL_HOME}/sources/ezproxy/sp_ebooks/scripts
SP_EBOOKS_DATA=${DASHYUL_DATA}/ebooks/scholarsportal

echo "------"
echo "Started: `date`"

echo -n "$YYYYMMDD: grepping ... "
zgrep -E viewdoc.html $EZPROXY_LOG_FULL_PATH | ${SP_EBOOKS_SCRIPTS}/extract-normalized-sp-ebook-ids.rb > /tmp/tmp-$YYYYMMDD-sp-ebook-raw.csv

echo -n "sorting ... "
sort --buffer-size 75% --parallel=4 /tmp/tmp-$YYYYMMDD-sp-ebook-raw.csv | uniq > /tmp/tmp-$YYYYMMDD-sp-ebook-views.csv
rm /tmp/tmp-$YYYYMMDD-sp-ebook-raw.csv

echo -n "merging ... "
${SP_EBOOKS_SCRIPTS}/merge-profile-affiliation-with-ebooks.R /tmp/tmp-$YYYYMMDD-sp-ebook-views.csv ${DASHYUL_DATA}/symphony/users/user-information.csv /tmp/tmp-$YYYYMMDD-sp-ebook-views-merged.csv

echo -n "SISing ... "
${DASHYUL_HOME}/sources/sis/scripts/get-student-information.rb /tmp/tmp-$YYYYMMDD-sp-ebook-views-merged.csv > /tmp/tmp-$YYYYMMDD-student-information.csv

echo -n "merging ..."
${SP_EBOOKS_SCRIPTS}/merge-all-information.R /tmp/tmp-$YYYYMMDD-sp-ebook-views-merged.csv /tmp/tmp-$YYYYMMDD-student-information.csv ${SP_EBOOKS_DATA}/sp-ebook-views-$YYYYMMDD.csv

rm -f /tmp/tmp-$YYYYMMDD-sp-ebook-views.csv
rm -f /tmp/tmp-$YYYYMMDD-sp-ebook-views-merged.csv
rm -f /tmp/tmp-$YYYYMMDD-student-information.csv

echo "Finished: `date`"
