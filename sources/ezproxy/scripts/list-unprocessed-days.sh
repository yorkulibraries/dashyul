#!/bin/bash

# Sometimes, for reasons I don't yet know, the full daily processing
# of the EZProxy logs fails and the -platform-detailed.csv is never
# generated.  This script lists all the days when this didn't happen.
# These days can then be run by hand.

EZPROXY_DATA=${DASHYUL_DATA}/ezproxy/current

suffix="-daily-users-per-host.csv"

for host_file in ${EZPROXY_DATA}/*${suffix}
do
    yyyymmdd=$(basename $host_file)
    # echo $yyyymmdd
    yyyymmdd=${yyyymmdd/${suffix}/}
    detail_file=${host_file/host/platform-detailed}
    #     echo $host_file
    #     echo $detail_file
    if ! [ -f $detail_file ]; then
	echo "${yyyymmdd}"
    fi
done
