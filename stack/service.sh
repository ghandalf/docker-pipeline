#!/bin/bash

###
## Use to work with current docker configuration
##
## Author: Francis Ouellet <fouellet@dminc.com>
###

## Output helper
dt="\t\t"
ndt="\n${dt}"

## Container files and directories
colors_resources=./resources/colors.properties

## Script command and arguments
# set -x
command=$1
args=($2 $3 $4 $5 $6 $7 $8 $9)

###
# Load properties files
##
function loadResources() {
	echo -e "${ndt}Loading resources...";

	if [ -f .env ]; then
		source .env;
	else
		echo -e "${ndt}You need to provide .env file under root ./ directory.";
		usage;
	fi
	if [ -f ${colors_resources} ]; then
		source ${colors_resources};
	else
		# No colors here, the file failed to be sourced
		echo -e "${ndt}You need to provide colors.properties, please look for this file: [${colors_resources}].\n";
		usage;
	fi
}

###
# Build container
# The prefix must be the company name or a project name
##
function build() {
	local size=${#args[*]}; 
	local prefix=${args[0]}

	if [[ $size > 0 ]] ; then
		for item in ${args[*]}; do
			if [[ $item == $prefix ]]; then
				continue;
			fi

			if [[ $item == "application" ]]; then
				# curl ${nexus_ghandalf_url} -o config/application/system/docker-deployment-6.0.0-SNAPSHOT.tar.gz
				. ./deploy.sh retrieveLatestSnapshot config/application/system
			fi
			docker build --rm -f ./config/$item/Dockerfile -t ${prefix}/$item:${CONTAINERS_VERSION} -t ${prefix}/$item:latest .

			if [ -f config/application/system/docker-deployment-6.0.0-SNAPSHOT.tar.gz ]; then
				rm -rf config/application/system/docker-deployment-6.0.0-SNAPSHOT.tar.gz
			fi
		done
	else
		echo -e "\n${dt}${BRed}Nothing to build, list length: $size. ${Color_Off}\n";
	fi
}

###
# Will start the services define in the compose file provided.
##
function start() {
	local compose_file=$1

	if [ ! -z ${compose_file} ]; then
		if [ -f ${compose_file} ]; then
			# Try to shutdown first.
			stop ${compose_file};
			docker-compose -f ${compose_file} up;
		else
			echo -e "${ndt}${BRed}The compose file [${compose_file}] provided didn't exists${Color_Off}.";
			usage;
		fi
	else
		echo -e "${ndt}${BRed}Please, you need to provide the compose file${Color_Off}.";
		usage;
	fi
}

###
# Will stop running services define in the given compose file.
##
function stop() {
	local compose_file=$1

	if [ ! -z ${compose_file} ]; then
		if [ -f ${compose_file} ]; then
			docker-compose -f ${compose_file} down;
		else
			echo -e "${ndt}${BRed}The compose file [${compose_file}] provided didn't exists${Color_Off}.";
			usage;
		fi
	else
		echo -e "${ndt}${BRed}Please, you need to provide the compose file${Color_Off}.";
		usage;
	fi
}

###
# Remove all containers, networks and force leaving the swarm due to manager container.
#
##
function clean() {

	echo -e "${dt}${Red}Are you sure you want to continue y|n?${Color_Off}.";
	read answer

	case $answer in
		"y"|"Y") 
			echo -e "${dt}${Red}Stopping containers `docker stop $(docker ps -aq)`${Color_Off}.";
			echo -e "${dt}${Red}Removing containers `docker rm $(docker ps -aq)`${Color_Off}.";
			echo -e "${dt}${Red}Removing dangling (tag none) containers `docker rmi $(docker images -f 'dangling=true' -q)`${Color_Off}.";
			#echo -e "${dt}${BRed}Removing images: `docker rmi $(docker images -aq)`${Color_Off}.";

			#local result=`docker network ls --filter 'name=${NETWORK_NAME}' | grep ${NETWORK_NAME} | awk {'printf $2'}`;
			#for network in "${networks[@]}"; do
			#	echo -e "${dt}${Red}Removing network: ${network} ${Color_Off}.";
			#	docker network rm ${network};
			#done
			;;
		"n"|"N") 
			exit ;;
		*) 
			echo -e "${ndt}${BRed}You must answer y or n${Color_Off}.";
			usage ;;
	esac

	echo -e "\n";
}

###
# Provide information on the services running.
##
function info() {
	local compose_file=$1

	if [ ! -z ${compose_file} ]; then
		if [ -f ${compose_file} ]; then
			echo -e "${ndt}${Yellow}Compose file validation:${Color_Off}[${Green}`docker-compose config`${Color_Off}].";
			echo -e "${ndt}${Yellow}Images:${Color_Off}[${Green}`docker images`${Color_Off}].";
			echo -e "${ndt}${Yellow}Running containers:${Color_Off}[${Green}`docker ps`${Color_Off}].";
			echo -e "${ndt}${Yellow}All containers:${Color_Off}[${Green}`docker ps -a`${Color_Off}].";
			echo -e "${ndt}${Yellow}List networks:${Color_Off}[${Green}`docker network ls`${Color_Off}].";
			echo -e "${ndt}${Yellow}List service:${Color_Off}[${Green}`docker service ls`${Color_Off}].";
			
			for container in `docker ps -a --format {{.Names}}`; do
				echo -e "${dt}${Yellow}$container${Color_Off} ip: [${Green}`docker container port $container`${Color_Off}]";
				echo -e "${dt}${Yellow}$container${Color_Off} log: [${Green}`docker inspect --format {{.LogPath}} $container`${Color_Off}]";
			done

			echo -e "${ndt}${Yellow}In case you need to install some tools in a container execute:${Color_Off}";
			echo -e "${dt}${dt}${Green}docker exec -u 0 -it <container name> bash -c \"<command>\"${Color_Off}";
			echo -e "${dt}${Yellow}To see the log of a container execute:${Color_Off}";
			echo -e "${dt}${dt}${Green}docker logs -f <containername>${Color_Off}\n";
		else
			echo -e "${ndt}${BRed}The compose file [${compose_file}] provided didn't exists${Color_Off}.";
			usage;
		fi
	else
		echo -e "${ndt}${BRed}Please, you need to provide the compose file${Color_Off}.";
		usage;
	fi
}

###
# Give the status of the current stack. 
# The presentation order will be:
# 		Gitlab, Jenkins, Nexus
##
function status() {
	# Check if we are in the host (Centos or Redhat)
	if [ "$(hostname)"=="devops.docker.com" ]; then
		echo -e "${dt}${Green}Checking for Gitlab: $(curl -s -o /dev/null -w "%{http_code}\n" http://devops.docker.com:32180) ${Color_Off}.";
		echo -e "${dt}${Green}Checking for Jenkins: $(curl -s -o /dev/null -w "%{http_code}\n" http://devops.docker.com:32280) ${Color_Off}.";
		echo -e "${dt}${Green}Checking for Nexus: $(curl -s -o /dev/null -w "%{http_code}\n" http://devops.docker.com:32380) ${Color_Off}.";
	else 
		echo -e "${dt}${Green}Checking for Gitlab: $(curl -s -o /dev/null -w "%{http_code}\n" http://gitlab:32180) ${Color_Off}.";
		echo -e "${dt}${Green}Checking for Jenkins: $(curl -s -o /dev/null -w "%{http_code}\n" http://jenkins:32280) ${Color_Off}.";
		echo -e "${dt}${Green}Checking for Nexus: $(curl -s -o /dev/null -w "%{http_code}\n" http://nexus:32380) ${Color_Off}.";
	fi
}

###
# Will connect to a running container
##
function connect() {
	local containerName=${args[0]}
	local type=${args[1]}

	if [ ! -z ${containerName} ]; then
			case ${type} in
				"root") 
					docker exec -u 0 -it ${containerName} /bin/bash;
					;;
				"user")
					docker exec -it ${containerName} /bin/bash;
					;;
				*)
					echo -e "${ndt}${BRed}Please, you need to provide the type of the connection root|user${Color_Off}.";
					usage;
					;;
			esac
	else
		echo -e "${ndt}${BRed}Please, you need to provide the name of the container${Color_Off}.";
		usage;
	fi
}

###
# Define how to use this script
##
function usage() {
  echo -e "${ndt}Usage:";
  echo -e "${dt}${Cyan}$0 ${Yellow}-b|b <prefix> <name>		${Green}Build the container using prefix in (docker,ghandalf) and name in (dev, qa, stage)${Color_Off}.";
	echo -e "${dt}${Yellow}			where ${Cyan}prefix	${Yellow}is the company or project name${Color_Off}.";
	echo -e "${dt}${Yellow}			where ${Cyan}name	${Yellow}must be in this list:(gitlab, jenkins, nexus)${Color_Off}.";
	echo -e "${dt}${Cyan}$0 ${On_IPurple}clean				${Green}Stop running containers, remove those and remove networks${Color_Off}.";
	echo -e "${dt}${Cyan}$0 ${Yellow}connect <name> <type>	${Green}Connect in bash mode to the given user type and container name${Color_Off}.";
	echo -e "${dt}${Yellow}			where ${Cyan}name	${Yellow}must be in this list:(gitlab, jenkins, nexus)${Color_Off}.";
	echo -e "${dt}${Yellow}			where ${Cyan}type	${Yellow}must be root or user${Color_Off}.";
	echo -e "${dt}${Cyan}$0 ${Yellow}-i|i <docker-compose-file>		${Green}Give minimal info on the containers for this stack, link to the compose file provided${Color_Off}.";
	echo -e "${dt}${Cyan}$0 ${Yellow}start <docker-compose-file>	${Green}Start the services define in the compose file provided${Color_Off}.";
	echo -e "${dt}${Cyan}$0 ${Yellow}status				${Green}Status of the running containers${Color_Off}.";
	echo -e "${dt}${Cyan}$0 ${Yellow}stop <docker-compose-file>		${Green}Stop the services define in the compose file provided${Color_Off}.";
	
	echo -e "${ndt}${Cyan}$0 ${On_IPurple} ATTENTION: using clean arguments could lead to data lost${Color_Off}.";
	echo -e "\n";
}

loadResources;
case ${command} in
	-b|b) 
		build $args ;;
	-i|i)
		info $args ;;
	start)
		start $args ;;
	stop)
		stop $args ;;
	status)
		status $args ;;
	connect)
		connect $args ;;
	clean)
		clean $args ;;
  *) 
		usage ;;
esac