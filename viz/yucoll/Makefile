YUCOLL_DATA := ${DASHYUL_DATA}/yucoll

all: prepare

prepare:
	cd scripts && ./yucoll-prepare.R
	gzip -f ${YUCOLL_DATA}/yucoll-data.csv

publish:
	rsync -avz --delete . orez:/srv/shiny-server/yucoll/
