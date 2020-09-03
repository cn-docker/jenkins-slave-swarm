FROM openjdk:16-jdk-slim-buster
LABEL maintainer="CN Services <noninojulian@gmail.com>"

# Update the system
RUN apt-get update -y && \
    apt-get install -y git subversion mercurial wget curl tzdata unzip xz-utils build-essential libssl-dev ruby ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Gradle
ENV GRADLE_VERSION 6.6.1
RUN echo "Install Gradle" && \
    wget https://downloads.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip && \
    unzip gradle-$GRADLE_VERSION-bin.zip && \
    mv gradle-$GRADLE_VERSION /opt/gradle && \
    rm -rf gradle-$GRADLE_VERSION-bin.zip
ENV GRADLE_HOME /opt/gradle
ENV PATH $GRADLE_HOME/bin:$PATH

# Install Maven
ENV MAVEN_VERSION 3.6.3
RUN echo "Install Maven"  && \
    wget http://apache.mirror.anlx.net/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    tar -zxf apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    mv apache-maven-$MAVEN_VERSION /opt/maven && \
    rm -rf apache-maven-$MAVEN_VERSION-bin.tar.gz
ENV MAVEN_HOME /opt/maven
ENV PATH $MAVEN_HOME/bin:$PATH

# Install Python
RUN echo "Install Python"  && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install PIP
COPY pip_requirements.txt /usr/local/bin/pip_requirements.txt
RUN echo "Install PIP"  && \
    curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && \
    python get-pip.py && \
    pip install -r /usr/local/bin/pip_requirements.txt && \
    rm -rf get-pip.py

# Install Node.js
ENV NODEJS_VERSION 14.9.0
RUN echo "Install Node.js"  && \
    wget https://nodejs.org/dist/v$NODEJS_VERSION/node-v$NODEJS_VERSION-linux-x64.tar.xz && \
    tar -xJf node-v$NODEJS_VERSION-linux-x64.tar.xz -C /usr/local --strip-components=1 && \
    rm node-v$NODEJS_VERSION-linux-x64.tar.xz

# Install Sonar Scanner
ENV SONAR_SCANNER_VERSION 4.4.0.2170
RUN echo "Install Sonar Scanner" && \
    wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip && \
    unzip sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip && \
    mv sonar-scanner-${SONAR_SCANNER_VERSION}-linux /opt/sonar-scanner && \
    rm -rf sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip  && \
    rm -rf /opt/sonar-scanner/conf/sonar-scanner.properties
ENV SONAR_SCANNER_HOME /opt/sonar-scanner
ENV PATH $SONAR_SCANNER_HOME/bin:$PATH

# Add Jenkins Worker user and add it to sudoers and create .m2 folder the user
RUN useradd -c "Jenkins Worker user" -d /home/jenkins-worker -m jenkins-worker && \
    echo "jenkins-worker ALL=NOPASSWD: ALL" >> /etc/sudoers

# Create Maven .m2 folder
RUN	mkdir /home/jenkins-worker/.m2 && \
   	mkdir /home/jenkins-worker/.m2/repository && \
   	chown -R jenkins-worker:jenkins-worker /home/jenkins-worker/.m2

# Copy Start script
COPY start_worker.sh /usr/local/bin/start_worker.sh

# Download Jenkins Swarm and condigure
ENV JENKINS_SWARM_VERSION 3.9
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-jar-with-dependencies.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar && \
    chmod 755 /usr/share/jenkins && \
    chmod +x /usr/local/bin/start_worker.sh

# Switch to Jenkins Worker user
USER jenkins-worker

# Copying default Maven Settings
COPY settings.xml /home/jenkins-worker/.m2/settings.xml

#Entrypoint
ENTRYPOINT ["/usr/local/bin/start_worker.sh"]
