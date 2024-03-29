FROM centos

LABEL Author="Francis Ouellet <fouellet@dminc.com>"
LABEL Description="Base on Centos 7"

ENV CONTAINER_NAME nexus
ENV CONTAINER_IMAGE ghandalf/nexus:${CONTAINERS_VERSION}
ENV CONTAINER_VERSION ${CONTAINERS_VERSION}
ENV APP_USER nexus
ENV APP_GROUP ngroup
ENV APP_HOME /usr/share/nexus

# JDK jdk1.8.0_202
ENV JAVA_VERSION jdk1.8.0_202
ENV JAVA_DIR /usr/share/java
ENV JAVA_HOME ${JAVA_DIR}/${JAVA_VERSION}

ENV NEXUS_VERSION latest
ENV NEXUS_FINAL_NAME nexus-${NEXUS_VERSION}
ENV NEXUS_HOME ${APP_HOME}/${NEXUS_FINAL_NAME}
ENV NEXUS_DATA ${APP_HOME}/data
ENV NEXUS_PORT 32280

RUN mkdir -p /usr/share/info/
# Error when the udapte is done:
#     Failed to get D-Bus connection: Operation not permitted
#   Keep in mind we are in a container and we building it, it is a normal behavior
RUN yum -y update
RUN yum --security check-update
RUN yum --security update
RUN yum install -y tree net-tools bind-utils wget mailx
RUN yum clean all

# Java installation
RUN mkdir -p ${JAVA_DIR}
#    JDK 8
RUN wget --no-cookies --no-check-certificate \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jdk-8u202-linux-x64.tar.gz \
    -P ${JAVA_DIR} \
    && tar xzf ${JAVA_DIR}/jdk-8*.tar.gz -C ${JAVA_DIR}/

# Configure alternatives to use installed JDK
RUN alternatives --install /usr/bin/java java ${JAVA_DIR}/${JAVA_VERSION}/bin/java 2 \
    && echo 1 | alternatives --config java \
    && alternatives --install /usr/bin/jar jar ${JAVA_DIR}/${JAVA_VERSION}/bin/jar 2 \
    && alternatives --install /usr/bin/javac javac ${JAVA_DIR}/${JAVA_VERSION}/bin/javac 2 \
    && alternatives --set jar ${JAVA_DIR}/${JAVA_VERSION}/bin/jar \
    && alternatives --set javac ${JAVA_DIR}/${JAVA_VERSION}/bin/javac \
    && java -version
#    JDK 8 done

# Nexus installation
RUN mkdir -p ${APP_HOME} ${NEXUS_DATA}/etc ${NEXUS_DATA}/logs ${NEXUS_DATA}/tmp \
    && wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz -P ${APP_HOME} \
    && tar xvf ${APP_HOME}/latest-unix.tar.gz -C ${APP_HOME} \
    && mv ${APP_HOME}/nexus-* ${APP_HOME}/${NEXUS_FINAL_NAME}

COPY ./config/nexus/system/service.sh ${APP_HOME}/
COPY ./config/nexus/system/conf/bin/nexus.vmoptions ${NEXUS_HOME}/bin/
COPY ./config/nexus/system/conf/etc/nexus.properties ${NEXUS_DATA}/etc/

RUN chmod 0755 ${APP_HOME}/service.sh

RUN groupadd -g 1002 ${APP_GROUP} \
    && useradd -r -u 1002 -M -b ${APP_HOME} -g ${APP_GROUP} ${APP_USER} \
    && usermod -s /sbin/nologin ${APP_USER} \
    && chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}
# Nexus installation done

# System configuration
# https://support.sonatype.com/hc/en-us/articles/213464868-Nexus-startup-fails-with-Could-not-lock-User-prefs-Couldn-t-flush-user-prefs-Couldn-t-get-file-lock-
COPY ./config/nexus/system/profile.d/java.sh /etc/profile.d/
RUN chmod 0644 /etc/profile.d/java.sh
COPY ./config/nexus/system/profile.d/nexus.sh /etc/profile.d/
RUN chmod 0644 /etc/profile.d/nexus.sh
# System configuration done

EXPOSE ${NEXUS_PORT}

# The USER instruction sets the user name (or UID) and optionally 
# the user group (or GID) to use when running the image and for 
# any RUN, CMD and ENTRYPOINT instructions that follow it in the Dockerfile.
USER ${APP_USER}

# Expect to have service.sh under rc.local or systemD, 
# so that starting the container will start the application
# ENTRYPOINT ["runuser", "-u", "nexus", "-g", "ngroup", "/usr/share/nexus/service.sh", "start"]
ENTRYPOINT ["/usr/share/nexus/service.sh", "start"]
