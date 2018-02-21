CIRCYUL_DATA := ${DASHYUL_DATA}/circyul
CIRCYUL_SERVER_SHINY := ${DASHYUL_SERVER_SHINY_DASHYUL}/circyul

all:	prepare

prepare:
	cd scripts && ./circyul-prepare.R
	gzip -f ${CIRCYUL_DATA}/*.csv

push_app:
	rsync -avz --delete . ${DASHYUL_SERVER_NAME}:${CIRCYUL_SERVER_SHINY}
