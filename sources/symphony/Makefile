all:

get_data:
	rsync -avz --copy-links ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/symphony/catalogue/catalogue-current* ${DASHYUL_DATA}/symphony/catalogue/
	rsync -avz ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/symphony/transactions/201[78]*csv ${DASHYUL_DATA}/symphony/transactions/
	rsync -avz ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/symphony/transactions/symphony-transactions* ${DASHYUL_DATA}/symphony/transactions/
