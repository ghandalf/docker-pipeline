#!/bin/bash

###
## Use to deploy the application in VM or Container
##
## Author: ghandalf@ghandalf.ca
###
application=$0
command=$1
args=($2 $3 $4 $5 $6 $7 $8 $9)

###
# Retrieve from Nexus the latest SNAPSHOT, be aware that is for development purpose only
# This method must not be used in any other environments other than dev
##
function retrieveLatestSnapshot() {
	local ouputDir=$1
	local url=http://devops.ghandalf.com:32280/repository/ghandalf-internal-snapshots/com/ghandalf/ghandalf-deployment/6.0.0-SNAPSHOT
	local suffix=tar.gz
	local projectName=ghandalf-deployment
	local outputName=${projectName}-6.0.0-SNAPSHOT.tar.gz

	local latest=$(curl -s "${url}/maven-metadata.xml" | \
		grep "<value>.*</value>" | \
		sed -e "s#\(.*\)\(<value>\)\(.*\)\(</value>\)\(.*\)#\3#g")
	
	local finaltUrl=${url}/${projectName}-${latest}.${suffix}

	curl "${finaltUrl}" -o ${ouputDir}/${outputName}

	tar xvf ${ouputDir}/${outputName} -C ${ouputDir}/ --strip-components=1
}

###
# Always need to convert from dos to unix, otherwise docker-compose fails to execute
# his task.
# Make sure that the tool dos2unix is installed.
##
function convert() {
	find ./${args[0]} -type f -exec dos2unix {} {} \;
}

echo -e "DEPLOY command: ${command} and args: ${args}"
case ${command} in
	retrieve) retrieveLatestSnapshot $args ;;
esac
