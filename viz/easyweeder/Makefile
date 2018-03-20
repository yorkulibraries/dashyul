EASYWEEDER_DATA := ${DASHYUL_DATA}/viz/easyweeder
EASYWEEDER_SERVER_SHINY := ${DASHYUL_SERVER_SHINY_DASHYUL}/easyweeder

all:	prepare

prepare:
	scripts/prepare-easyweeder.R
	gzip -f ${EASYWEEDER_DATA}/*.csv

get_data:
	rsync --archive --verbose --compress ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/viz/easyweeder/ ${EASYWEEDER_DATA}/

push_app:
	rsync --archive --verbose --compress --delete app/ ${DASHYUL_SERVER_NAME}:${EASYWEEDER_SERVER_SHINY}
