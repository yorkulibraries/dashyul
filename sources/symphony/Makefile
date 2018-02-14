all:

get_data:
	rsync -avz --copy-links vm1:/data/symphony/data/catalogue/catalogue-current* ${DASHYUL_DATA}/symphony/catalogue/
	rsync -avz vm1:/data/symphony/data/transactions/201[78]*csv ${DASHYUL_DATA}/symphony/transactions/
	rsync -avz vm1:/data/symphony/data/transactions/symphony-transactions* ${DASHYUL_DATA}/symphony/transactions/
