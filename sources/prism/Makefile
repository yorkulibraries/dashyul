PRISM_DATA := ${DASHYUL_DATA}/prism/

all:

push_data:
	rsync --archive --verbose --compress ${PRISM_DATA} ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/prism/
