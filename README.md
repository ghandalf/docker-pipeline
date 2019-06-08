# README

Main container, of my CI/CD Pipeline. This project goal is to provide containers linked which created our Pipeline. Those docker containers will be apply On premise or Cloud, this page is to explain how we prepare the On Premise VM or the Cloud deployement.

## This repository

 *ci-cd-pipeline* Entry point of the project, On Premise or Cloud deployment<br>
 *stack*: Sub project with docker container
```bash
docker-pipeline/
├── INFO.BFKP
├── README.md
└── stack
    ├── config
    ├── docker-compose-application.yml
    ├── docker-compose.yml
    ├── README.md
    ├── resources
    └── service.sh
```

### Set up VirtualBox

You need to install VirtualBox on your local machine, follow this [link](https://www.virtualbox.org/wiki/Downloads) to do so.

### Set up Centos 7 Guest on VirtualBox

We will use Centos 7 server, it is the open source of Redhat 7 (RHEL):

```bash
1. Download Centos 7 Minimal choose the nearest mirror from this [list](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso);
2. Start Virtualbox, click on new button and follow the instructions;
3. Once the VM is created before you start it, increase the display: click on settings under Screen tab increase the Scale Factor to 150%. We will not install Virtualbox Guests Additions, a server don\'t need any User Interface.
4. Proceed with a normal installation as root for now.
5. Create a user:
    - useradd "username"
    - passwd "username"
    - usermod -aG wheel "username"
    - exit
6. From now on we will use this user for our installation. This is a best practice, we want to avoid doing "sudo su -" command. We want to be able to trace who does changes on the server. Later in time, we will configure root user to avoid ssh connection from anywhere.
```

Configure Network between Guest and Host, we want to use a DNS name instead of ip address.

```bash
1. Log with the new user on the guest Centos 7, we will proceed to our installation.
2. Activate external access:
    as root:
    nmcli d
      enp0s3 etherner disconnected
    nmtui
      Edit a connection
        Ethernet
          enp0s3
            Edit Enter
            [X] Automatically connect
    service network restart
3. sudo hostnamectl set-hostname devops.docker.com
4. sudo shutdown now
4. From Virtualbox click on the Centos 7 VM, click on Settings button
    - Click on "Network"
    - Click on "Adapter 1" tab
    - Make sure you have  attached to: "NAT"
    - Click on "Adapter 2" tab
    - Click on "Enable Network Adapter"
    - Choose Attached to: "Host-only Adapter"
    - save
5. Start the Centos 7 guest
   Todo: Configure ip static ! inside guest or tru DHCP in Virtualbox host
    Static Ip
     1. Edit hosts file and add this following line at the end
         - sudo vi /etc/hosts
         - At the end of the line beginning by 127.0.0.1 for ip 4 and ::1 for ip 6 add "devops devops.docker.com"
        - Save and exit the file. The command ping devops or devops.docker.com should return localhost 127.0.0.1
6. Set hostname
    sudo hostnamectl set-hostname devops.docker.com
    /etc/resolv.con add those values
    nameserver 8.8.8.8
    nameserver 192.168.56.1
7. Important part, we want our host to have access to the same DNS name as the Guest, because we don\'t control the DNS server, here is what we need to do:
    - On the Host machine (the machine where Virtualbox was installed)
    - Open on any linux like machine, /etc/hosts file, on Windows the file is under
      C:\Windows\System32\drivers\etc\hosts
        Add "192.168.56.102 devops devops.docker.com" at the end of the file
    - Save the file
```

### Set up Docker installation

Docker will be used instead of multiple VMs.

```bash
1. Log as super user in Centos 7 guest
2. sudo yum install -y yum-utils device-mapper-persistent-data lvm2 bind-utils bridge-utils
3. sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
4. sudo yum install -y docker-ce
5. sudo usermod -aG docker $(whoami) // Add power user to docker group created by the installation above.
6. sudo systemctl enable docker.service // Start docker at boot time
7. sudo sustemctl start docker.service or sudo service docker start
8. sudo yum install -y epel-release
9. sudo yum install -y python-pip // Dependencies
10. sudo pip install docker-compose // Python installator
11. sudo yum upgrade python* // Will upgrade python-perf libraries in Python 8.1.2
12. docker-compose -version // check if we can run docker-compose
13. sudo yum clean all
```

### Important task

Increase the mmap count for docker. Elasticsearch uses a mmapfs directory to stores his indices.<br>
CentOs or RedHat limits the mmap count to solve this problem and respect the standard for sysctl service.<br>
We need to create a new file under /etc/sysctl.d directory as root that we will name docker.conf.<br>
Then insert this line in the file vm.max_map_count = 262144. This will set this value permanently.


### Set up Svn and Git client on the server to retrieve docker-pipeline project

docker-Pipeline is the project that contain the Pipeline stack [Gitlab, Jenkins and Nexus]. We also have the Application to experiment deployement process.

```bash
1. Log as super user
2. sudo vi /etc/yum.repos.d/Wandisco-svn.repo
    _Copy this text in the file_:
    [WandiscoSVN]
    name=Wandisco SVN Repo
    baseurl=http://opensource.wandisco.com/centos/$releasever/svn-1.8/RPMS/$basearch/
    enabled=1
    gpgcheck=0
3. save the file by executing this command in the editor: ESC : wq!
4. sudo yum remove subversion // In case we have an old version
5. sudo yum clean all
6. sudo yum install -y subversion
7. svn --version // check the installation
8. sudo vi /etc/yum.repos.d/Wandisco-git.repo
    -Copy this text in the file_:
    [WandiscoGit]
    name=Wandisco GIT Repository
    baseurl=http://opensource.wandisco.com/centos/7/git/$basearch/
    enabled=1
    gpgcheck=1
    gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
9. save the file by executing this command in the editor: ESC : wq!
10. sudo yum remove git // In case we have an old version
11. sudo yum clean all
12. sudo yum install -y git
13. git --version // check the installation
```

### Retrieve docker-pipeline project and the services

This project we use to generate and deploy on this server all the stack. To execute those commands you will need to activate your VPN connection to Rackspace in your Host machine (Your Windows machine).

```bash
1. Log as super user
2. sudo vi /etc/hosts
    Add the following at the end of the file:
    # Access Rackspace VPN
    192.237.229.122 vpn.rackspace.com
    # Use to avoid Ip Address, once connected to Racksapce VPN, use those DNS names to navigate
    172.21.0.35 tools.rackspace.com # Jenkins:8080, Nexus:8081, Sonar Qube:9000, Suversion:/svn/wwwCFNAcom, Nagios:/nagios/, Splunk:8000
    172.21.0.45 dev.rackspace.com # Linux Virtual Machine call Linux Box
3. save the file by executing this command in the editor: ESC : wq!
4. mkdir -p workspace/docker/docker-pipeline // Create a workspace in your account
5. cd workspace/docker // move under the workspace/docker directory
6. svn co --username <your username in svn> http://172.21.0.35/svn/wwwCFNAcom/docker-pipeline/trunk docker-pipeline
7. It will ask for: Store password unencrypted (yes/no)? no // Best practice will say avoid unencrypted password
8. cd docker-pipeline/stack
9. Make sure that in docker-compose.yml the services you need are uncommented.
10. ./service.sh build jenkins // Remember you must be in docker group
11. docker images 
     You should see something like:
     REPOSITORY             TAG                 IMAGE ID        CREATED             SIZE
     ghandalf/jenkins     0.0.1-SNAPSHOT      8eef010d326d    About a minute ago  2.96GB
     ghandalf/jenkins     latest              8eef010d326d    About a minute ago  2.96GB
     centos               latest              1e1148e4cc2c    7 weeks ago         202MB
12. ./service.sh build nexus
13. docker images
     You should see something like: // Don\'t worry the Snapshot is a pointer to latest
     REPOSITORY             TAG                 IMAGE ID        CREATED             SIZE
     ghandalf/jenkins     0.0.1-SNAPSHOT      8eef010d326d    About a minute ago  2.96GB
     ghandalf/jenkins     latest              8eef010d326d    About a minute ago  2.96GB
     ghandalf/nexus       0.0.1-SNAPSHOT      8eef010d326d    About a minute ago  2.96GB
     ghandalf/nexus       latest              8eef010d326d    About a minute ago  2.96GB
     centos               latest              1e1148e4cc2c    7 weeks ago         202MB
```

### Startup all containers

The container must be build and deploy locally. We will have to provice a hub to keep those containers versions.

./service.sh start

Keep an eye on the stack trace it is where you will be able to retrieve the password for Jenkins.
You may have the well know problem that have Jenkins, white screen after the first login or after the first configuration. To solve it stop the stack and restart it.

### Deploy application and configuration

To do this part, we need to connect to the docker host and create a hidden directory

```bash
    1. log on the Virtual Machine: 999726-cicdsrv1.docker.com
    2. go under docker-pipeline/stack
    3. chmod 750 deploy.sh
    2. Execute the following lines:
       a) sudo mkdir -p /usr/local/hidden/dev
       b) sudo mkdir -p /usr/local/hidden/qa
       c) sudo mkdir -p /usr/local/hidden/stage
    3. Create secret files
       a) sudo touch /usr/local/hidden/dev/.service
       b) sudo touch /usr/local/hidden/dev/.application
       c) sudo touch /usr/local/hidden/qa/.service
       d) sudo touch /usr/local/hidden/qa/.application
       e) sudo touch /usr/local/hidden/stage/.service
       f) sudo touch /usr/local/hidden/stage/.application
    4. Edit .service as sudo and insert values, here is an example
        google_geo_api_key=DEV-@!~!$Fd45%$dxSon#!+=0_-_#
        mitek_api_client_secret=DEV-NeedThisSecret

    5) Protect hidden directories and files
       a) sudo chown -R root:docker /usr/local/hidden
       b) sudo chmod -R 0450 /usr/local/hidden
```

### Install Cisco AnyConnect Client to reach rackspace

1. Log as super user
2. Install java first
    sudo mkdir -p /usr/share/java
    sudo yum install -y wget
    sudo wget --no-cookies --no-check-certificate \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jdk-8u202-linux-x64.tar.gz \
    -P /usr/share/java
    sudo tar xzf /usr/share/java/jdk-8*.tar.gz -C /usr/share/java/
    sudo mv /usr/share/java/jdk1.* /usr/share/java/jdk1.8
    sudo echo "export JAVA_HOME=/usr/share/jave/jdk1.8" > java.sh
    source java.sh
    sudo echo "export PATH=${JAVA_HOME}/bin:${PATH}" >> java.sh
    sudo mv java.sh /etc/profile.d/
    sudo chmod 0644 /etc/profile.d/java.sh
    source /etc/profile.d/java.sh
3. Install vpnc client
    sudo yum-config-manager repos --enable rhel-7-server-optional-rpms
    sudo yum install -y vpnc
    




3. Install Cisco AnyConnect Client - We may need to provide username/password to access Cisco Download instead of this third party
    sudo mkdir -p /usr/share/cisco
    sudo wget https://www.itechtics.com/?dl_id=15 -P /usr/share/cisco/
    sudo mv /usr/share/cisco/index* /usr/share/cisco/anyconnect-linux64-4.5.03040-predeploy-k9.tar.gz
    sudo tar xzf /usr/share/cisco/anyconnect* -C /usr/share/cisco/

2. sudo yum install pangox-compat pangox-compat-devel

2. sudo yum install -y openvpn easy-rsa
3. sudo cp /usr/share/doc/openvpn-*/sample/sample-config-files/server.conf /etc/openvpn/ // Copy template
4. sudo chown root:openvpn /etc/openvpn/server.conf
5. sudo vi /etc/openvpn/server.conf // We may need to change the DNS access
    push "dhcp-option DNS 8.8.8.8"
    push "dhcp-option DNS 8.8.4.4"
6. sudo mkdir -p /etc/openvpn/easy-rsa/keys
7. sudo cp -rf /usr/share/easy-rsa/3.0.3/* /etc/openvpn/easy-rsa/
8. sudo chown -R root:openvpn /etc/openvpn/
9. sudo vi /etc/openvpn/easy-rsa/vars

### Installing diagnostic tools on guest

1. Log as super user
2. sudo yum install epel-release // Already installed
3. sudo 

### Contribution guidelines

* Code review
* Other guidelines

### Technical advice

* Use https://cloud.google.com/knative/, could be very nice to have.

### Resources

* Repo owner: Francis Ouellet, <fouellet@dminc.com>
* Community: docker team - Internal project only.
