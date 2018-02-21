all:

setup_data_directories:
	test -n "$(DASHYUL_DATA)" # Is $$DASHYUL_DATA set?
	sudo mkdir -p ${DASHYUL_DATA}
	sudo chown ${USER}:${USER} ${DASHYUL_DATA}
	mkdir -p ${DASHYUL_DATA}/circyul
	mkdir -p ${DASHYUL_DATA}/dashboard
	mkdir -p ${DASHYUL_DATA}/ebooks/scholarsportal
	mkdir -p ${DASHYUL_DATA}/ezproxy
	mkdir -p ${DASHYUL_DATA}/libstats
	mkdir -p ${DASHYUL_DATA}/symphony/catalogue
	mkdir -p ${DASHYUL_DATA}/symphony/transactions
	mkdir -p ${DASHYUL_DATA}/symphony/users
	mkdir -p ${DASHYUL_DATA}/yucoll
	mkdir -p ${DASHYUL_DATA}/yudesk
