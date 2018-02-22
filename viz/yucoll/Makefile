YUCOLL_DATA := ${DASHYUL_DATA}/yucoll
YUCOLL_SERVER_SHINY := ${DASHYUL_SERVER_SHINY_DASHYUL}/yucoll

all: prepare

prepare:
	scripts/yucoll-prepare.R
	gzip -f ${YUCOLL_DATA}/yucoll-data.csv

get_data:
	rsync --archive --verbose --compress ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/yucoll/ ${YUCOLL_DATA}/

push_app:
	rsync -avz --delete . ${DASHYUL_SERVER_NAME}:${YUCOLL_SERVER_SHINY}
