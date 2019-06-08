FROM centos

LABEL Author="Francis Ouellet <fouellet@dminc.com>"
LABEL Description="Base on Centos 7"

ENV CONTAINER_NAME gitlab
ENV CONTAINER_IMAGE ghandalf/gitlab:${CONTAINERS_VERSION}
ENV CONTAINER_VERSION ${CONTAINERS_VERSION}
ENV APP_USER gitlab
ENV APP_GROUP ggroup
ENV APP_HOME /usr/share/gitlab

ENV GITLAB_HOME ${APP_HOME}
ENV GITLAB_PORT_HTTP 32184
ENV GITLAB_PORT_SSH 32122
ENV GITLAB_PORT_HTTPS 32143

ENV HOSTNAME gitlab.ghandalf.com
ENV EXTERNAL_URL="http://${HOSTNAME}"

# Install from source : https://docs.gitlab.com/ee/install/installation.html
RUN yum -y update
RUN yum clean all

# Install dependencies Ruby and native extensions to Ruby gems
RUN yum install -y ruby rubygems
RUN yum groupinstall -y 'Development Tools'
RUN yum install -y rubygems

# sudo apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libre2-dev \
#   libreadline-dev libncurses5-dev libffi-dev curl openssh-server checkinstall libxml2-dev \
#   libxslt-dev libcurl4-openssl-dev libicu-dev logrotate rsync python-docutils pkg-config cmake


EXPOSE ${GITLAB_PORT_HTTP}
EXPOSE ${GITLAB_PORT_SSH}
EXPOSE ${GITLAB_PORT_HTTPS}

USER ${APP_USER}

ENTRYPOINT [ "/bin/sh" ]
