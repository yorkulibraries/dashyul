GARDENER_SERVER_SHINY := ${DASHYUL_SERVER_SHINY_DASHYUL}/gardener

all:	prepare

prepare:

push_app:
	rsync --archive --verbose --compress --delete app/ ${DASHYUL_SERVER_NAME}:${GARDENER_SERVER_SHINY}
