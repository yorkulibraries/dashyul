get_data:
	rsync -avz --copy-links ${DASHYUL_SERVER_NAME}:${DASHYUL_SERVER_DATA}/ezproxy/ ${DASHYUL_DATA}/ezproxy/

annual_metrics:
	./scripts/prepare-platform-metrics.R
