all:

metrics:
	./scripts/prepare-item-circ-history.R
	./scripts/prepare-circ-metrics.R

simple_checkouts:
	./scripts/aggregate-simple-checkouts-past.R
	./scripts/aggregate-simple-checkouts-current.R
	./scripts/aggregate-simple-checkouts-all.R

detailed_transactions:
	./scripts/aggregate-detailed-transactions-current.R

get_data:
	rsync -avz --copy-links ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/symphony/catalogue/catalogue-current* ${DASHYUL_DATA}/symphony/catalogue/
	rsync -avz ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/symphony/transactions/ ${DASHYUL_DATA}/symphony/transactions/
	rsync -avz ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/symphony/transactions/symphony-transactions* ${DASHYUL_DATA}/symphony/transactions/
	rsync -avz ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/symphony/metrics/ ${DASHYUL_DATA}/symphony/metrics/
