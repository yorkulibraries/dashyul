CIRCYUL_DATA := ${DASHYUL_DATA}/circyul

all:	prepare

prepare:
	cd scripts && ./circyul-prepare.R
	gzip -f ${CIRCYUL_DATA}/*.csv

publish:
	rsync -avz --delete . orez:/srv/shiny-server/circyul/
