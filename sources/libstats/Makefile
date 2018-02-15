LIBSTATS_DATA := ${DASHYUL_DATA}/libstats

all:	fetch clean

fetch:
	curl --silent --cookie login=${LIBSTATS_LOGIN_COOKIE} "https://www.library.yorku.ca/libstats/reportReturn.do?date1=&date2=&library_id=&location_id=&report_id=DataCSVReport" -o ${LIBSTATS_DATA}/all_libraries.csv

clean: # ${LIBSTATS_DATA}/all_libraries.csv
	scripts/clean-up-libstats.rb ${LIBSTATS_DATA}/all_libraries.csv > ${LIBSTATS_DATA}/libstats.csv
	rm ${LIBSTATS_DATA}/all_libraries.csv

daily: data/libstats.csv
	cd scripts; ./dashboard-libstats-daily-summary.R
