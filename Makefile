all:

setup_data_directories:
	test -n "$(DASHYUL_DATA)" # Is $$DASHYUL_DATA set?
	sudo mkdir -p ${DASHYUL_DATA}
	sudo chown ${USER}:${USER} ${DASHYUL_DATA}
	mkdir -p ${DASHYUL_DATA}/symphony/catalogue/ ${DASHYUL_DATA}/symphony/transactions/
	mkdir -p $(DASHYUL_DATA}/libstats $(DASHYUL_DATA}/yudesk $(DASHYUL_DATA}/circyul $(DASHYUL_DATA}/yucoll
