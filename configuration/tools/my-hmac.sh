#!/bin/sh

printf "Enter your Username and press [ENTER]: \n"
read USER_NAME

printf "Enter your Secret and press [ENTER]: \n"
read SECRET

printf "Enter your Request URL (e.g.: https://example.com:8443/test) and press [ENTER]: \n"
read REQ_URL

printf "Enter your Request Method (e.g.: GET) and press [ENTER]: \n"
read REQ_METHOD

printf "Enter your Request Body and press [ENTER]: \n"
read REQ_BODY


REQ_HOST=$(echo $REQ_URL | sed -e 's/^.*:\/\///' -e 's/\/.*$//')
REQ_PATH=$(echo $REQ_URL | sed -e 's/^.*:\/\///' -e 's/[^\/]*//')
REQ_METHOD=$(echo $REQ_METHOD | sed 's/.\+/\U\0/')
REQ_LINE="$REQ_METHOD $REQ_PATH HTTP/1.1"

TS=$(LC_TIME=C date -u "+%a, %d %b %Y %T %Z")

SIGNSTR="date: $TS"
HEADERS="date"

echo "\n*********************************************************************"
echo "* Include the following headers in your HMAC Auth request to Kong:"
echo "**********************************************************************"
echo "Date: $TS"

if [ ! -z "$REQ_LINE" ]
then
    SIGNSTR="$SIGNSTR\n$REQ_LINE"
    HEADERS="$HEADERS request-line"
fi

if [ ! -z "$REQ_HOST" ]
then
    SIGNSTR="$SIGNSTR\nhost: $REQ_HOST"
    HEADERS="$HEADERS host"
fi

if [ ! -z "$REQ_BODY" ]
then
    DIGEST=$(printf "$REQ_BODY" | openssl dgst -sha256 -binary | openssl enc -base64 -A)
    echo "Digest: SHA-256=$DIGEST"
    SIGNSTR="$SIGNSTR\ndigest: SHA-256=$DIGEST"
    HEADERS="$HEADERS digest"
fi

HMAC=$(printf "$SIGNSTR" | openssl dgst -sha256 -hmac $SECRET -binary | openssl enc -base64 -A)
AUTH="hmac username=\"$USER_NAME\", algorithm=\"hmac-sha256\", headers=\"$HEADERS\", signature=\"$HMAC\""
echo "Authorization: $AUTH"
