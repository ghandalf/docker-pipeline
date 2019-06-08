# Create to source specific files in /etc/profile.d/*.sh
# This case is for a no-login shell in Docker container
# Hardcode path are for security reasons

if [ -r /etc/profile.d/ant.sh ]; then . /etc/profile.d/ant.sh; fi
if [ -r /etc/profile.d/java.sh ]; then . /etc/profile.d/java.sh; fi
if [ -r /etc/profile.d/jenkins.sh ]; then . /etc/profile.d/jenkins.sh; fi
if [ -r /etc/profile.d/maven.sh ]; then . /etc/profile.d/maven.sh; fi
if [ -r /etc/profile.d/nodejs.sh ]; then . /etc/profile.d/nodejs.sh; fi
if [ -r /etc/profile.d/sonarqube.sh ]; then . /etc/profile.d/sonarqube.sh; fi
