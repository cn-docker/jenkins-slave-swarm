# Jenkins Worker

[![](https://img.shields.io/docker/pulls/cnservices/jenkins-slave-swarm.svg)](https://hub.docker.com/r/cnservices/jenkins-slave-swarm/)
[![](hhttps://img.shields.io/docker/build/cnservices/jenkins-slave-swarm)](https://hub.docker.com/r/cnservices/jenkins-slave-swarm/)
[![](https://img.shields.io/docker/automated/cnservices/jenkins-slave-swarm)](https://hub.docker.com/r/cnservices/jenkins-slave-swarm/)
[![](https://img.shields.io/docker/stars/cnservices/jenkins-slave-swarm)](https://hub.docker.com/r/cnservices/jenkins-slave-swarm/)
[![](https://img.shields.io/github/license/cn-docker/jenkins-slave-swarm)](https://github.com/cn-docker/jenkins-slave-swarm)
[![](https://img.shields.io/github/issues/cn-docker/jenkins-slave-swarm)](https://github.com/cn-docker/jenkins-slave-swarm)
[![](https://img.shields.io/github/issues-closed/cn-docker/jenkins-slave-swarm)](https://github.com/cn-docker/jenkins-slave-swarm)
[![](https://img.shields.io/github/languages/code-size/cn-docker/jenkins-slave-swarm)](https://github.com/cn-docker/jenkins-slave-swarm)
[![](https://img.shields.io/github/repo-size/cn-docker/jenkins-slave-swarm)](https://github.com/cn-docker/jenkins-slave-swarm)

You can build the Docker Image with the following command:

    docker build -t jenkins-swarm-worker .

The worker will be labeled "ubuntu-worker".

### Start Jenkins Workers ###

Create a folder to store worker files so you can keep them even if the container is restarted.

    mkdir ~/jenkins_worker_data
    chmod 777 ~/jenkins_worker_data

Build the Docker Image

    docker build -t jenkins-worker jenkins-worker/

Run the Jenkins Worker, you need to provide Jenkins Master URL and the number of executors this worker should have.

    docker run -d --restart=always -v ~/jenkins_worker_data:/home/jenkins-worker/workspace jenkins-swarm-worker -master http://${JENKINS_MASTER_ADDRESS}:8080 -executors <NUMBER_OF_EXECUTORS>
