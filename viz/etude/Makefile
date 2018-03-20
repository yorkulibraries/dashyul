ETUDE_DATA := ${DASHYUL_DATA}/viz/etude
ETUDE_SERVER_SHINY := ${DASHYUL_SERVER_SHINY_DASHYUL}/etude

all:

get_data:
	rsync --archive --verbose --compress ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/viz/etude/ ${ETUDE_DATA}/

push_app:
	rsync --archive --verbose --compress --delete app/ ${DASHYUL_SERVER_NAME}:${ETUDE_SERVER_SHINY}
