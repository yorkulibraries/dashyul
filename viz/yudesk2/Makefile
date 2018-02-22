YUDESK_DATA := ${DASHYUL_DATA}/yudesk
YUDESK2_SERVER_SHINY := ${DASHYUL_SERVER_SHINY_DASHYUL}/yudesk2

all: prepare

prepare:
	scripts/yudesk-summarize.R
	gzip -f ${YUDESK_DATA}/yudesk-summary.csv

copydata:
	cp -p ${YUDESK_DATA}/yudesk-summary.csv.gz /srv/shiny-server/yudesk2/data/

push_app:
	rsync -avz Makefile index.Rmd ${DASHYUL_SERVER_NAME}:${YUDESK2_SERVER_SHINY}/
