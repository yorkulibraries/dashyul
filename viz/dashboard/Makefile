DASHBOARD_DATA := ${DASHYUL_DATA}/viz/dashboard
DASHBOARD_SERVER_SHINY := ${DASHYUL_SERVER_SHINY_DASHBOARD}

all:	prepare

prepare:

libstats_today:
	scripts/get-libstats-today.rb > ${DASHBOARD_DATA}/libstats-today.csv

get_data:
	rsync --archive --verbose --compress ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/viz/dashboard/ ${DASHBOARD_DATA}/

push_app:
	rsync -avz --delete . ${DASHYUL_SERVER_NAME}:${DASHBOARD_SERVER_SHINY}
