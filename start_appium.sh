#!/bin/bash

BL='\033[0;34m'
G='\033[0;32m'
RED='\033[0;31m'
YE='\033[1;33m'
NC='\033[0m' # No Color

function start_appium () {
    if [[ "$APPIUM_PORT" == "" ]] || [[ "$APPIUM_PORT" == null ]]; then
        printf "${G}==>  ${YE}No port provided, instance will run on 4723 ${G}<==${NC}""\n"
        A_PORT="4723"
    else
        printf "${G}==>  ${BL}Instance will run on ${YE}${APPIUM_PORT} ${G}<==${NC}""\n"
        A_PORT="${APPIUM_PORT}"
    fi

case "$1" in
    "hub")
        params="-ka 800 --use-plugins=device-farm --config ./appium-node.json -pa /wd/hub"
    ;;
    "node")
        params="-ka 800 --use-plugins=device-farm --config ./appium-hub.json -pa /wd/hub"
    ;;
    *)
        echo "default (none of above)"
    ;;
esac


    appium -p $APPIUM_PORT
};

start_appium
