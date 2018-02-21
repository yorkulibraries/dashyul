all:

setup_data_directories:
	test -n "$(DASHYUL_DATA)" # Is $$DASHYUL_DATA set?
	sudo mkdir -p ${DASHYUL_DATA}
	sudo chown ${USER}:${USER} ${DASHYUL_DATA}
	mkdir -p ${DASHYUL_DATA}/symphony/catalogue ${DASHYUL_DATA}/symphony/transactions ${DASHYUL_DATA}/symphony/users
	mkdir -p ${DASHYUL_DATA}/libstats ${DASHYUL_DATA}/yudesk ${DASHYUL_DATA}/circyul
	mkdir -p ${DASHYUL_DATA}/yucoll ${DASHYUL_DATA}/ezproxy ${DASHYUL_DATA}/ebooks/scholarsportal
