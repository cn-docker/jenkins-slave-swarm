# Jenkins Slave #

Jenkins Slaves are build from an Ubuntu Xenial base and have this tools by default:  
- Java JDK 8 update 121
- Maven 3.3.9
- Ant 1.10.1
- Python 2.7.12
- Python PIP 8.1.2

You can build the Docker Image with the following command:  

    docker build -t jenkins-slave jenkins-slave/

The slave will be labeled "ubuntu-slave".

### Start Jenkins Slaves ###

Create a folder to store slave files so you can keep them even if the container is restarted.  
    
    mkdir ~/jenkins_slave_data
    chmod 777 ~/jenkins_slave_data

Build the Docker Image

    docker build -t jenkins-slave jenkins-slave/

Run the Jenkins Slave, you need to provide Jenkins Master URL and the number of executors this slave should have.  

    docker run -d --restart=always -v ~/jenkins_slave_data:/home/jenkins-slave/workspace jenkins-slave -master http://${JENKINS_MASTER_ADDRESS}:8080 -executors <NUMBER_OF_EXECUTORS>