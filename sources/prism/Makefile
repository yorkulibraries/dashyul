PRISM_DATA := ${DASHYUL_DATA}/prism/

all: prepare

prepare:
	scripts/process-prism-data.R

get_data:
	rsync --archive --verbose --compress ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/prism/ ${PRISM_DATA}

push_data:
	rsync --archive --verbose --compress ${PRISM_DATA} ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/prism/
