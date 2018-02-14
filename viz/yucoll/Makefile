all:

prepare:
	rm -f data/yucoll-data.csv.gz
	cd scripts && ./yucoll-prepare.R
	gzip data/yucoll-data.csv

publish:
	rsync -avz --delete . orez:/srv/shiny-server/yucoll/
