FROM openjdk:11-jdk
LABEL maintainer="Julian Nonino <noninojulian@gmail.com>"

# Update the system
RUN apt-get update -y && \
    apt-get install -y git subversion mercurial wget curl tzdata unzip xz-utils build-essential libssl-dev ruby ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

# Install Gradle
ENV GRADLE_VERSION 5.6.2
RUN echo "Install Gradle" && \
    wget https://downloads.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip && \
    unzip gradle-$GRADLE_VERSION-bin.zip && \
    mv gradle-$GRADLE_VERSION /opt/gradle && \
    rm -rf gradle-$GRADLE_VERSION-bin.zip
ENV GRADLE_HOME /opt/gradle
ENV PATH $GRADLE_HOME/bin:$PATH

# Install Maven
ENV MAVEN_VERSION 3.6.2
RUN echo "Install Maven"  && \
    wget http://apache.mirror.anlx.net/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    tar -zxf apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    mv apache-maven-$MAVEN_VERSION /opt/maven && \
    rm -rf apache-maven-$MAVEN_VERSION-bin.tar.gz
ENV MAVEN_HOME /opt/maven
ENV PATH $MAVEN_HOME/bin:$PATH

# Install Python
ENV PYTHON_VERSION 2.7.16
ENV PYTHON_PIP_VERSION 19.2.3
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y python2.7 python-pip && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
COPY pip_requirements.txt /usr/local/bin/pip_requirements.txt
RUN pip install -r /usr/local/bin/pip_requirements.txt

# Install Node.js
ENV NODEJS_VERSION 12.10.0
RUN wget https://nodejs.org/dist/v$NODEJS_VERSION/node-v$NODEJS_VERSION-linux-x64.tar.xz && \
    tar -xJf node-v$NODEJS_VERSION-linux-x64.tar.xz -C /usr/local --strip-components=1 && \
    rm node-v$NODEJS_VERSION-linux-x64.tar.xz

# Install Sonar Runner
ENV SONAR_RUNNER_VERSION 2.4
RUN echo "Install Sonar Runner" && \
    wget http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist/$SONAR_RUNNER_VERSION/sonar-runner-dist-$SONAR_RUNNER_VERSION.zip && \
    unzip sonar-runner-dist-$SONAR_RUNNER_VERSION.zip && \
    mv sonar-runner-$SONAR_RUNNER_VERSION /opt/sonar-runner && \
    rm -rf sonar-runner-dist-$SONAR_RUNNER_VERSION.zip && \
    rm -rf /opt/sonar-runner/conf/sonar-runner.properties
ENV SONAR_RUNNER_HOME /opt/sonar-runner
ENV PATH $SONAR_RUNNER_HOME/bin:$PATH

# Add Jenkins Slave user and add it to sudoers and create .m2 folder the user
RUN useradd -c "Jenkins Slave user" -d /home/jenkins-slave -m jenkins-slave && \
    echo "jenkins-slave ALL=NOPASSWD: ALL" >> /etc/sudoers

# Create Maven .m2 folder
RUN	mkdir /home/jenkins-slave/.m2 && \
   	mkdir /home/jenkins-slave/.m2/repository && \
   	chown -R jenkins-slave:jenkins-slave /home/jenkins-slave/.m2

# Copy Start script
COPY start_slave.sh /usr/local/bin/start_slave.sh

# Download Jenkins Swarm and condigure
ENV JENKINS_SWARM_VERSION 3.9
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-jar-with-dependencies.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar && \
    chmod 755 /usr/share/jenkins && \
    chmod +x /usr/local/bin/start_slave.sh

# Switch to Jenkins Slave user
USER jenkins-slave

# Copying default Maven Settings
COPY settings.xml /home/jenkins-slave/.m2/settings.xml

#Entrypoint
ENTRYPOINT ["/usr/local/bin/start_slave.sh"]
