YUDESK_DATA := ${DASHYUL_DATA}/yudesk

all: prepare

prepare:
	rm -f ${YUDESK_DATA}/yudesk-summary.csv.gz
	scripts/yudesk-summarize.R
	gzip ${YUDESK_DATA}/yudesk-summary.csv

copydata:
	cp -p ${YUDESK_DATA}/yudesk-summary.csv.gz /srv/shiny-server/yudesk2/data/

push_app:
	rsync -avz Makefile index.Rmd ${DSAHYUL_SERVER_NAME}:/srv/shiny-server/yudesk2/
