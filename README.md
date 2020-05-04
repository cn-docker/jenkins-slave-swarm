# Jenkins Slave

[![](https://img.shields.io/docker/pulls/cnservices/jenkins-slave-swarm.svg)](https://hub.docker.com/r/cnservices/jenkins-slave-swarm/)
[![](hhttps://img.shields.io/docker/build/cnservices/jenkins-slave-swarm)](https://hub.docker.com/r/cnservices/jenkins-slave-swarm/)
[![](https://img.shields.io/docker/automated/cnservices/jenkins-slave-swarm)](https://hub.docker.com/r/cnservices/jenkins-slave-swarm/)
[![](https://img.shields.io/docker/stars/cnservices/jenkins-slave-swarm)](https://hub.docker.com/r/cnservices/jenkins-slave-swarm/)
[![](https://img.shields.io/github/license/cn-docker/jenkins-slave-swarm)](https://github.com/cn-docker/jenkins-slave-swarm)
[![](https://img.shields.io/github/issues/cn-docker/jenkins-slave-swarm)](https://github.com/cn-docker/jenkins-slave-swarm)
[![](https://img.shields.io/github/issues-closed/cn-docker/jenkins-slave-swarm)](https://github.com/cn-docker/jenkins-slave-swarm)
[![](https://img.shields.io/github/languages/code-size/cn-docker/jenkins-slave-swarm)](https://github.com/cn-docker/jenkins-slave-swarm)
[![](https://img.shields.io/github/repo-size/cn-docker/jenkins-slave-swarm)](https://github.com/cn-docker/jenkins-slave-swarm)

Jenkins Slaves are build from an Ubuntu Xenial base and have this tools by default:  

- Java JDK 10  
- Gradle 4.10.2  
- Maven 3.6.0   
- Python 2.7
- Python 3
- Node.js 10.13.0
- Sonar Runner 2.4
- Jenkins Swarm 3.9

You can build the Docker Image with the following command:  

    docker build -t jenkins-swarm-slave .

The slave will be labeled "ubuntu-slave".

### Start Jenkins Slaves ###

Create a folder to store slave files so you can keep them even if the container is restarted.  
    
    mkdir ~/jenkins_slave_data
    chmod 777 ~/jenkins_slave_data

Build the Docker Image

    docker build -t jenkins-slave jenkins-slave/

Run the Jenkins Slave, you need to provide Jenkins Master URL and the number of executors this slave should have.  

    docker run -d --restart=always -v ~/jenkins_slave_data:/home/jenkins-slave/workspace jenkins-swarm-slave -master http://${JENKINS_MASTER_ADDRESS}:8080 -executors <NUMBER_OF_EXECUTORS>
