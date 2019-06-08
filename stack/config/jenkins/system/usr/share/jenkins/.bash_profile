# Create for security reason and 
# source for the no-login user /etc/profile.d/*.sh
# For more information see: https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html

if [ -f ~/.bashrc ]; then
    . ~/.bashrc;
fi