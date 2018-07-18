GARDENER_DATA := ${DASHYUL_DATA}/viz/gardener
GARDENER_SERVER_SHINY := ${DASHYUL_SERVER_SHINY_DASHYUL}/gardener

all:	prepare

prepare:
	./scripts/prepare-gardener.R
	gzip -f ${GARDENER_DATA}/*csv

push_app:
	rsync --archive --verbose --compress --delete app/ ${DASHYUL_SERVER_NAME}:${GARDENER_SERVER_SHINY}
