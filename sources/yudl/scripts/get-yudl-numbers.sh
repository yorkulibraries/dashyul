#!/usr/bin/env bash

DASHBOARD_DATA=${DASHYUL_DATA}/viz/dashboard

YUDL_COUNT_FILE=${DASHBOARD_DATA}/yudl-current-total-objects.txt

echo "------"
echo "Started: `date`"

curl https://digital.library.yorku.ca/yudl-current-total-objects.txt -o ${YUDL_COUNT_FILE}
