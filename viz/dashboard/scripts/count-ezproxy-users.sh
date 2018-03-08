#!/usr/bin/env bash

EZP_CURRENT_DATA=${DASHYUL_DATA}/ezproxy/current
DASHBOARD_DATA=${DASHYUL_DATA}/viz/dashboard

YESTERDAY="${DASHBOARD_DATA}/ezp-users-yesterday.txt"
TODAY="${DASHBOARD_DATA}/ezp-users-today.txt"

echo "------"
echo "Started: `date`"

mv $TODAY $YESTERDAY

cut -d, -f2 ${EZP_CURRENT_DATA}/*detailed* | sort | uniq | wc -l > $TODAY

echo "Finished: `date`"
