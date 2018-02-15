CIRCYUL_DATA := ${DASHYUL_DATA}/circyul

all:	prepare

prepare:
	cd scripts && ./circyul-prepare.R
	gzip -f ${CIRCYUL_DATA}/*.csv

push_app:
	rsync -avz --delete . ${DASHYUL_SERVER_NAME}:/srv/shiny-server/circyul/
