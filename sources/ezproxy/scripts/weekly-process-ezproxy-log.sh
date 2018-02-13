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

# Get the Oracle environment variables.
source ~/.bash.vm1.rc

# Run the Ruby under RVM
# TODO: Use proper system-wide Ruby.
RVM_PATH=`~/.rvm/bin/rvm env --path -- ruby-version[@gemset-name]`
source $RVM_PATH

EZPROXY_LOG_FULL_PATH=$1

if [ -z $EZPROXY_LOG_FULL_PATH ]
then
    EZPROXY_LOG_FULL_PATH=`ls -rt /accesslogs/ezproxy.log-20* | tail -1`
fi

YYYYMMDD=`basename -s .gz $EZPROXY_LOG_FULL_PATH | sed 's/ezproxy.log-//'`

cd /data/ezproxy/

echo -n "$YYYYMMDD: grepping ... "
gunzip -c $EZPROXY_LOG_FULL_PATH | scripts/extract-date-userbarcode-host.rb > tmp-$YYYYMMDD-host.csv

echo -n "uniqing ... "
uniq tmp-$YYYYMMDD-host.csv > tmp-$YYYYMMDD-uniq.csv
rm tmp-$YYYYMMDD-host.csv

echo -n "sorting ... "
sort -S 75% -n tmp-$YYYYMMDD-uniq.csv > tmp-$YYYYMMDD-uniq-sorted.csv
rm tmp-$YYYYMMDD-uniq.csv

echo -n "uniqing ... "
uniq tmp-$YYYYMMDD-uniq-sorted.csv > weekly/data/$YYYYMMDD-daily-users-per-host.csv
rm tmp-$YYYYMMDD-uniq-sorted.csv

echo -n "platforming ... "
scripts/rename-hosts-to-platforms.rb weekly/data/$YYYYMMDD-daily-users-per-host.csv | sort -n -S 75% | uniq > weekly/data/$YYYYMMDD-daily-users-per-platform.csv

echo -n "merging ... "
scripts/weekly-merge-profile-affiliation-with-platform.R weekly/data/$YYYYMMDD-daily-users-per-platform.csv /data/users/user-information.csv tmp-$YYYYMMDD-merged.csv

echo -n "SISing ... "
/data/users/scripts/get-student-information.rb tmp-$YYYYMMDD-merged.csv > tmp-$YYYYMMDD-student-information.csv

echo -n "merging ..."
scripts/weekly-merge-all-information.R tmp-$YYYYMMDD-merged.csv tmp-$YYYYMMDD-student-information.csv weekly/data/$YYYYMMDD-daily-users-per-platform-detailed.csv

rm tmp-$YYYYMMDD-merged.csv
rm tmp-$YYYYMMDD-student-information.csv
