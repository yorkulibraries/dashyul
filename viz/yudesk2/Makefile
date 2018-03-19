YUDESK_DATA := ${DASHYUL_DATA}/viz/yudesk
YUDESK2_SERVER_SHINY := ${DASHYUL_SERVER_SHINY_DASHYUL}/yudesk2

all: prepare

prepare:
	echo "------"
	echo "Started: `date`"
	scripts/prepare-yudesk.R
	gzip -f ${YUDESK_DATA}/yudesk-summary.csv
	echo "Finished: `date`"

get_data:
	rsync --archive --verbose --compress ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/viz/yudesk/ ${YUDESK_DATA}/

push_app:
	rsync --archive --verbose --compress --delete app/ ${DASHYUL_SERVER_NAME}:${YUDESK2_SERVER_SHINY}/
