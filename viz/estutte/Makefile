ESTUTTE_DATA := ${DASHYUL_DATA}/viz/estutte
ESTUTTE_SERVER_SHINY := ${DASHYUL_SERVER_SHINY_DASHYUL}/estutte

all: prepare

prepare:
	scripts/prepare-estutte.R

get_data:
	rsync --archive --verbose --compress ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/viz/estutte/ ${ESTUTTE_DATA}/

push_app:
	rsync --archive --verbose --compress --delete app/ ${DASHYUL_SERVER_NAME}:${ESTUTTE_SERVER_SHINY}
