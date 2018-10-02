CIRCYUL_DATA := ${DASHYUL_DATA}/viz/circyul
CIRCYUL_SERVER_SHINY := ${DASHYUL_SERVER_SHINY_DASHYUL}/circyul

all:	prepare

prepare:
	scripts/prepare-circyul.R

get_data:
	rsync --archive --verbose --compress ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/viz/circyul/ ${CIRCYUL_DATA}/

push_app:
	rsync --archive --verbose --compress --delete app/ ${DASHYUL_SERVER_NAME}:${CIRCYUL_SERVER_SHINY}
