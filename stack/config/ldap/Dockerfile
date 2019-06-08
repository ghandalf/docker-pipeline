FROM centos

LABEL Author="Francis Ouellet <fouellet@dminc.com>"
LABEL Description="Base on Centos 7"

ENV CONTAINER_NAME ldap
ENV CONTAINER_IMAGE ghandalf/ldap:${CONTAINERS_VERSION}
ENV CONTAINER_VERSION ${CONTAINERS_VERSION}
ENV APP_USER ldap
ENV APP_GROUP lgroup
ENV APP_HOME /usr/share/ldap
ENV LDAP_HOME ${APP_HOME}
ENV LDAP_PORT 666

ENV BDB_HOME /usr/share/bekeley

RUN yum -y update
RUN yum --security check-update
RUN yum --security update
RUN yum install -y tree net-tools openldap openldap-servers openldap-clients openssl

COPY ./config/ldap/system/etc/openldap/ldap.conf /etc/openldap/ldap.conf
COPY ./config/ldap/system/etc/openldap/slapd.conf /etc/openldap/slapd.conf

RUN ldapmodify -a -h host1 -p 1389 -D cn=admin,cn=Administrators,cn=config -w -
RUN cat /etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif | grep 

# Install Berkeley DB
# RUN mkdir -p ${BDB_HOME}
# COPY ./config/ldap/system/db-18.1.25.tar.gz ${BDB_HOME}/
# RUN tar xvf ${BDB_HOME}/db*.tar.gz -C ${BDB_HOME}/
# RUN ls -la ${BDB_HOME}
# RUN cd ${BDB_HOME}/db-18.1.25/build_unix \
#     && ../dist/configure \
#     && make \
#     && make install
#RUN cd ${BDB_HOME}/

# Install 
# RUN mkdir -p ${APP_HOME}
# RUN wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.47.tgz \
#     -P ${APP_HOME}/
# RUN tar xvf ${APP_HOME}/openldap*.tgz -C ${APP_HOME}/
# RUN groupadd -g 1002 ${APP_GROUP} \
#     && useradd -r -u 1002 -M -d ${APP_HOME}/data -g ${APP_GROUP} ${APP_USER} \
#     && usermod -s /sbin/nologin ${APP_USER} \
#     && chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}
# RUN yum install -y libtool zlib-devel openssl-headers
# RUN cd ${APP_HOME}/openldap-2.4.47 \
#     && export LD_LIBRARY_PATH=/usr/local/BerkeleyDB.18.1/lib:$LD_LIBRARY_PATH \
#         # CPPFLAGS="-D_GNU_SOURCE -I/usr/local/BerkeleyDB.18.1/include" \ 
#         # LDFLAGS=-L/usr/local/BerkeleyDB.18.1/lib \
#         ./configure
    # --prefix=${APP_HOME} \
    # --exec-prefix=${APP_HOME} \
    # --datarootdir=${APP_HOME}/data \
    # --enable-slapd --enable-crypt
# Install OpenLDAP done

EXPOSE ${LDAP_PORT}

# USER ${APP_USER}

# ENTRYPOINT ["/usr/share/jenkins/service.sh", "start"]

