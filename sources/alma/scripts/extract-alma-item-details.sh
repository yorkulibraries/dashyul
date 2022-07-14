#!/bin/sh

cd $DASHYUL_DATA/alma/items/
report_number=$(ls PHYSICAL_ITEM_* | tail -1 | sed 's/PHYSICAL_ITEM_//' | sed 's/_.*//')

echo $report_number
