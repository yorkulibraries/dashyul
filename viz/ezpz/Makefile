EZPZ_DATA := ${DASHYUL_DATA}/viz/ezpz
EZPZ_SERVER_SHINY := ${DASHYUL_SERVER_SHINY_DASHYUL}/ezpz

all:	prepare

prepare:
	scripts/prepare-ezpz.R
	gzip -f ${EZPZ_DATA}/*csv

push_app:
	rsync --archive --verbose --compress --delete app/ ${DASHYUL_SERVER_NAME}:${EZPZ_SERVER_SHINY}
