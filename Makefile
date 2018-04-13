all:

setup_directories:
	test -n "$(DASHYUL_DATA)" # Is $$DASHYUL_DATA set?
	sudo mkdir -p ${DASHYUL_DATA}
	sudo chown ${USER}:${USER} ${DASHYUL_DATA}
	mkdir -p ${DASHYUL_DATA}/ebooks/scholarsportal
	mkdir -p ${DASHYUL_DATA}/ezproxy
	mkdir -p ${DASHYUL_DATA}/libstats
	mkdir -p ${DASHYUL_DATA}/prism
	mkdir -p ${DASHYUL_DATA}/symphony/catalogue
	mkdir -p ${DASHYUL_DATA}/symphony/metrics
	mkdir -p ${DASHYUL_DATA}/symphony/transactions
	mkdir -p ${DASHYUL_DATA}/symphony/users
	mkdir -p ${DASHYUL_DATA}/viz
	mkdir -p ${DASHYUL_DATA}/viz/circyul
	mkdir -p ${DASHYUL_DATA}/viz/dashboard
	mkdir -p ${DASHYUL_DATA}/viz/easyweeder
	mkdir -p ${DASHYUL_DATA}/viz/etude
	mkdir -p ${DASHYUL_DATA}/viz/ezpz
	mkdir -p ${DASHYUL_DATA}/viz/yucoll
	mkdir -p ${DASHYUL_DATA}/viz/yudesk
	test -n "$(DASHYUL_LOGS)" # Is $$DASHYUL_DATA set?
	sudo mkdir -p ${DASHYUL_LOGS}
	sudo chown ${USER}:${USER} ${DASHYUL_LOGS}
	test -n "$(DASHYUL_SHINY_DASHYUL)"
	sudo mkdir -p ${DASHYUL_SHINY_DASHYUL}
	sudo chown ${USER}:${USER} ${DASHYUL_SHINY_DASHYUL}
	mkdir -p ${DASHYUL_SHINY_DASHYUL}/circyul
	mkdir -p ${DASHYUL_SHINY_DASHYUL}/easyweeder
	mkdir -p ${DASHYUL_SHINY_DASHYUL}/etude
	mkdir -p ${DASHYUL_SHINY_DASHYUL}/ezpz
	mkdir -p ${DASHYUL_SHINY_DASHYUL}/yucoll
	mkdir -p ${DASHYUL_SHINY_DASHYUL}/yudesk2
	test -n "$(DASHYUL_SHINY_DASHBOARD)"
	sudo mkdir -p ${DASHYUL_SHINY_DASHBOARD}
	sudo chown ${USER}:${USER} ${DASHYUL_SHINY_DASHBOARD}
