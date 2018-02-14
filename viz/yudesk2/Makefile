all:

prepare:
	rm -f data/yudesk-summary.csv.gz
	scripts/yudesk-summarize.R
	gzip data/yudesk-summary.csv

copydata:
	cp -p data/yudesk-summary.csv.gz /srv/shiny-server/yudesk2/data/

publish:
	rsync -avz Makefile index.Rmd orez:/srv/shiny-server/yudesk2/
