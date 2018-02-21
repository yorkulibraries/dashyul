#!/bin/bash

# Process an EZProxy log file.
#
# If no file is specified, it will use the most recent one in /accesslogs/.
#
# $ ./process-latest-log.sh
#
# To specify a file, you must use the full path, eg /accesslogs/ezproxy.log-20151108.gz
#
# $ ./process-latest-log.sh /accesslogs/ezproxy.log-20151108.gz
#
# This script depends on the logs being named ezproxy.log-YYYYMMDD.gz.

EZPROXY_LOG_FULL_PATH=$1

if [ -z $EZPROXY_LOG_FULL_PATH ]
then
    EZPROXY_LOG_FULL_PATH=`ls -rt /accesslogs/ezproxy.log-20* | tail -1`
fi

YYYYMMDD=`basename -s .gz $EZPROXY_LOG_FULL_PATH | sed 's/ezproxy.log-//'`

EZPROXY_SCRIPTS=${DASHYUL_HOME}/sources/ezproxy/scripts
EZPROXY_DATA=${DASHYUL_DATA}/ezproxy

echo "------"
echo "Started: `date`"

echo -n "$YYYYMMDD: grepping ... "
gunzip -c $EZPROXY_LOG_FULL_PATH | ${EZPROXY_SCRIPTS}/extract-date-userbarcode-host.rb > /tmp/tmp-$YYYYMMDD-host.csv

echo -n "uniqing ... "
uniq /tmp/tmp-$YYYYMMDD-host.csv > /tmp/tmp-$YYYYMMDD-uniq.csv
rm /tmp/tmp-$YYYYMMDD-host.csv

echo -n "sorting ... "
sort --buffer-size 75% --parallel=4 --numeric-sort /tmp/tmp-$YYYYMMDD-uniq.csv > /tmp/tmp-$YYYYMMDD-uniq-sorted.csv
rm /tmp/tmp-$YYYYMMDD-uniq.csv

echo -n "uniqing ... "
uniq /tmp/tmp-$YYYYMMDD-uniq-sorted.csv > ${EZPROXY_DATA}/$YYYYMMDD-daily-users-per-host.csv
rm /tmp/tmp-$YYYYMMDD-uniq-sorted.csv

echo -n "platforming ... "
${EZPROXY_SCRIPTS}/rename-hosts-to-platforms.rb ${EZPROXY_DATA}/$YYYYMMDD-daily-users-per-host.csv | sort --buffer-size 75% --parallel=4 --numeric-sort | uniq > ${EZPROXY_DATA}/$YYYYMMDD-daily-users-per-platform.csv

echo -n "merging ... "
${EZPROXY_SCRIPTS}/ezp-merge-profile-affiliation-with-platform.R ${EZPROXY_DATA}/$YYYYMMDD-daily-users-per-platform.csv ${DASHYUL_DATA}/symphony/users/user-information.csv /tmp/tmp-$YYYYMMDD-merged.csv

echo -n "SISing ... "
${DASHYUL_HOME}/sources/sis/scripts/get-student-information.rb /tmp/tmp-$YYYYMMDD-merged.csv > /tmp/tmp-$YYYYMMDD-student-information.csv

echo -n "merging ..."
${EZPROXY_SCRIPTS}/ezp-merge-all-information.R /tmp/tmp-$YYYYMMDD-merged.csv /tmp/tmp-$YYYYMMDD-student-information.csv ${EZPROXY_DATA}/$YYYYMMDD-daily-users-per-platform-detailed.csv

rm /tmp/tmp-$YYYYMMDD-merged.csv
rm /tmp/tmp-$YYYYMMDD-student-information.csv

echo "Finished: `date`"
