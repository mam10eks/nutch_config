#!/bin/bash -e

function clean_crawl()
{

	if [ "$#" == "1" ] && [ -n "$1" ] && [ "$1" != "/" ] && [ -d "${1}/crawl" ]; then
		echo "clean crawl: ${1}"
		find ${1}/* -maxdepth 1 \( -name "crawldb" -o -name "linkdb" \) -exec rm -Rf {} \;
		find ${1}/crawl/segments/ -maxdepth 2 \( -name "crawl_parse" -o -name "parse_data" -o -name "parse_text" \) -exec rm -Rf {} \;
	else
		echo "ILLEGAL USAGE OF clean_crawl..."
		exit 1
	fi
}

function nutch_parse()
{

	if [ "$#" == "1" ] && [ -n "$1" ] && [ "$1" != "/" ] && [ -d "${1}/crawl/segments" ]; then
		for SEGMENT in ${1}/crawl/segments/*; do
			echo "Parse segment: ${SEGMENT}"
			nutch parse ${SEGMENT}
		done
	else
		echo "ILLEGAL USAGE OF nutch_parse..."
		exit 1
	fi
}


############################################################################
# Start temporary solr
############################################################################

sudo rm -Rf solr_cores

cp -r initial_cores_config solr_cores
sudo chown -R 8983:8983 solr_cores

CONTAINER_ID=$(docker run -d -p "8983:8983" -v "${PWD}/solr_container_init_volumes/solr_cores:/opt/solr/server/solr/" solr:7.1.0)

if [ -z "${CONTAINER_ID}" ]; then
	echo "Seems like container couldnt be started since the id is ${CONTAINER_ID}"
	exit 1
fi



############################################################################
# Process crawled data and index it
############################################################################

RESULT_DIR="total_crawl"

rm -Rf ${RESULT_DIR} && mkdir ${RESULT_DIR}

CRAWL_DIRECTORIES=("theol.uni-leipzig.de")
ALL_SEGMENTS=""
for CRAWL_DIRECTORY in "${CRAWL_DIRECTORIES[@]}"
do
	clean_crawl "${CRAWL_DIRECTORY}"
	nutch_parse "${CRAWL_DIRECTORY}"
	nutch updatedb "${RESULT_DIR}/crawldb" ${CRAWL_DIRECTORY}/crawl/segments/*
	nutch invertlinks "${RESULT_DIR}/linkdb" ${CRAWL_DIRECTORY}/crawl/segments/*
	ALL_SEGMENTS="${ALL_SEGMENTS} ${CRAWL_DIRECTORY}/crawl/segments/*"
done

nutch dedup "${RESULT_DIR}/crawldb"
nutch solrindex http://localhost:8983/solr/uni_leipzig_core "${RESULT_DIR}/crawldb" -linkdb "${RESULT_DIR}/linkdb" $(echo "${ALL_SEGMENTS}")


############################################################################
# Shutdown Solr
############################################################################

docker kill ${CONTAINER_ID}
docker rm ${CONTAINER_ID}