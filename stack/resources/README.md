# Archictecture evolution

The scope of software architecture is a combination of auditibility, performance, security, requirements, data, legality, and scalability. The domain and business requirements are part of the architecture.

Software becomes to be harder to change over time. 

The infrastructue present here, is base on those combinations enonces above.


## Basic representation

_**Release One**_<br>
A basic implementation of a pipeline, at the end we retrieve the artifact from Nexus and deploy on DEV server. For the other environments, the pattern will be:
    Log on DEV, pull the application from nexus and deploy;
    Log on QA, pull the application from the previous environment DEV;
    Log on STAGING, pull the application from the previous environment QA;
    Log on PROD, pull the application from previous environment STAGING.

Be aware that the CI/CD pipeline has nothing to do with the application. The Credit First representation is to easy comprehension.

![Release One](./images/architecture/ArchitectureReleaseOne.png)


_**Release Two**_<br>
This release implies the Elastic stack on a single node. To the Credit First application belongs here. Important note, for this release the application will not be in a container but deploy in the same virtual machine then the Elastic stack.

![Release Two](./images/architecture/ArchitectureReleaseTwo.png)


_**Release Three**_<br>
This release implies a container for the V6 application. We are preparing the scalability.

![Release Three](./images/architecture/ArchitectureReleaseThree.png)


_**Release Four**_<br>
Implement the scalability could be on Rackspace or AWS.

![Release Four](./images/architecture/ArchitectureReleaseFour.png)



_**Release Five**_<br>
Aws and Kubernetes, they are the tools which will manage on demand the replication of the virtual containers.

![Release Five](./images/architecture/ArchitectureReleaseFive.png)