LIBSTATS_DATA := ../../data/libstats

all:	fetch prepare

fetch:
	# This is a login cookie from once when I logged in. Expires in 2037!
	curl --silent --cookie login=${LIBSTATS_LOGIN_COOKIE} "https://www.library.yorku.ca/libstats/reportReturn.do?date1=&date2=&library_id=&location_id=&report_id=DataCSVReport" -o ${LIBSTATS_DATA}/all_libraries.csv

prepare: ${LIBSTATS_DATA}/all_libraries.csv
	scripts/clean-up-libstats.rb ${LIBSTATS_DATA}/all_libraries.csv > ${LIBSTATS_DATA}/libstats.csv
	rm ${LIBSTATS_DATA}/all_libraries.csv

daily: data/libstats.csv
	cd scripts; ./dashboard-libstats-daily-summary.R

#publish:
#	rsync -avz Makefile scripts vm1:/data/libstats/

yudesk_summary:
	rm -f data/yudesk-summary.csv.gz
	cd scripts; ./yudesk-summarize.R
	gzip data/yudesk-summary.csv
