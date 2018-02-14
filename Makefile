# all:

local_setup:
	test -n "$(DASHYUL_HOME)" # Is $$DASHYUL_HOME set?
	test -n "$(DASHYUL_DATA)" # Is $$DASHYUL_DATA set?
	sudo mkdir -p ${DASHYUL_DATA}
	sudo chown ${USER}:${USER} ${DASHYUL_DATA}
	mkdir -p ${DASHYUL_DATA}/symphony/catalogue/
	mkdir -p ${DASHYUL_DATA}/symphony/transactions/
	mkdir -p ${DASHYUL_DATA}/symphony/catalogue/
	mkdir -p ${DASHYUL_DATA}/libstats/

get_symphony_data:
	rsync -avz --copy-links vm1:/data/symphony/data/catalogue/catalogue-current* ${DASHYUL_DATA}/symphony/catalogue/
	rsync -avz vm1:/data/symphony/data/transactions/201[78]*csv ${DASHYUL_DATA}/symphony/transactions/
	rsync -avz vm1:/data/symphony/data/transactions/symphony-transactions* ${DASHYUL_DATA}/symphony/transactions/
