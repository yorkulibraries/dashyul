LIBSTATS_DATA := ${DASHYUL_DATA}/libstats

all:
	scripts/get-libstats-by-year.rb > ${LIBSTATS_DATA}/libstats-current.csv
	scripts/aggregate-libstats.R

old_all:	fetch clean

fetch:
	curl --silent --cookie login=${LIBSTATS_LOGIN_COOKIE} "https://www.library.yorku.ca/libstats/reportReturn.do?date1=&date2=&library_id=&location_id=&report_id=DataCSVReport" -o ${LIBSTATS_DATA}/all_libraries.csv

clean:
	scripts/process-libstats-data.rb ${LIBSTATS_DATA}/all_libraries.csv > ${LIBSTATS_DATA}/libstats.csv
	rm ${LIBSTATS_DATA}/all_libraries.csv

daily:
	scripts/extract-dashboard-libstats-daily-summary.R
