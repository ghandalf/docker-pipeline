#!/bin/bash

command=$1

function start() {
    echo -e "Starting Jenkins server...";
    
    # Use to start Jenkins on jdk 8 using our timezone
    java -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York -DJENKINS_HOME=${JENKINS_HOME}/data -jar ${JENKINS_HOME}/bin/jenkins.war --httpPort=${JENKINS_PORT}
    
    # java -DJENKINS_HOME=${JENKINS_HOME}/data -jar ${JENKINS_HOME}/bin/jenkins.war --httpPort=${JENKINS_PORT}
    
    # Use to start Jenkins on jdk 11 using our timezone
    # see: https://jenkins.io/blog/2018/12/14/java11-preview-availability/
    # java -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York \ 
    #     -p ${JENKINS_HOME}/bin/jaxb-api.jar:${JENKINS_HOME}/bin/javax.activation.jar \
    #     --add-modules ${JENKINS_HOME}/bin/java.xml.bind,${JENKINS_HOME}/bin/java.activation \
    #     -cp ${JENKINS_HOME}/bin/jaxb-core.jar:${JENKINS_HOME}/bin/jaxb-impl.jar \
    #     -jar ${JENKINS_HOME}/bin/jenkins.war \
    #     --enable-future-java --httpPort=${JENKINS_PORT} --prefix=/jenkins
}

###
# Gracefull shutdown is manage by docker
##
function stop() {
    echo -e "Stop experimental implementation ...";
    curl http://localhost:${JENKINS_PORT}/exit
}

function usage() {
    echo -e "$0 start|stop"
}

case ${command} in
    start) start ;;
    stop) stop ;;
    *) usage ;;
esac
