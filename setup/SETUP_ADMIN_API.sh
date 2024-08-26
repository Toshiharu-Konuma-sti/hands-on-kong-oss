#!/bin/sh

call_curl_post_ptrn_files()
{
	for PATHFILE in $PWD$1; do
		API_URL=http://localhost:8001/$2
		echo "\n--------------------------------------------------"
		echo $PATHFILE
		curl -v -X POST \
			$API_URL \
			-H 'Content-Type: application/json' \
			-d @$PATHFILE
	done
}

call_curl_post_credential_files()
{
	for PATHFILE in $PWD$1; do
		PG_NAME=`echo $PATHFILE | sed -e 's/.*\/cd-//' -e 's/\.json$//'`
		API_URL=http://localhost:8001/$2/$3/$PG_NAME
		echo "\n--------------------------------------------------"
		echo $PATHFILE
		curl -v -X POST \
			$API_URL \
			-H 'Content-Type: application/json' \
			-d @$PATHFILE
	done
}


echo "####################\n### START\n####################"

PTN_SV=/service/sv-*.json
URI_SV=services
PTN_RT=/route/rt-*.json
URI_RT=routes
PTN_PG=/plugin/pg-*.json
URI_PG=plugins
PTN_CN=/consumer/consumer.json
URI_CN=consumers
PTN_CD=/consumer/cd-*.json
URI_CD=$URI_CN
USERNM=taro.sios

call_curl_post_ptrn_files $PTN_SV $URI_SV
call_curl_post_ptrn_files $PTN_RT $URI_RT
call_curl_post_ptrn_files $PTN_PG $URI_PG
call_curl_post_ptrn_files $PTN_CN $URI_CN
call_curl_post_credential_files $PTN_CD $URI_CD $USERNM

echo "\n####################\n### FINISH\n####################"
