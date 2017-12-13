FROM ubuntu:xenial
LABEL maintainer="Julian Nonino <noninojulian@outlook.com>"

# Update the system
RUN apt-get update -y && \
    apt-get install -y git wget curl tzdata unzip xz-utils build-essential libssl-dev ruby && \
    rm -rf /var/lib/apt/lists/*

# Install Java 8 JDK Update 141
RUN echo "Install Java 8 JDK Update 141" && \
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.tar.gz && \
    tar -zxf jdk-8u151-linux-x64.tar.gz && \
    mv jdk1.8.0_151 /opt/java && \
    rm -rf jdk-8u151-linux-x64.tar.gz
ENV JAVA_HOME /opt/java
ENV PATH $JAVA_HOME/bin:$PATH

# Install Gradle 4.1
RUN echo "Install Gradle 4.1" && \
    wget https://downloads.gradle.org/distributions/gradle-4.1-bin.zip && \
    unzip gradle-4.1-bin.zip && \
    mv gradle-4.1 /opt/gradle && \
    rm -rf gradle-4.1-bin.zip
ENV GRADLE_HOME /opt/gradle
ENV PATH $GRADLE_HOME/bin:$PATH

# Install Maven 3.5.0
RUN echo "Install Maven 3.5.0"  && \
    wget http://apache.dattatec.com/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz && \
    tar -zxf apache-maven-3.5.0-bin.tar.gz && \
    mv apache-maven-3.5.0 /opt/maven && \
    rm -rf apache-maven-3.5.0-bin.tar.gz
ENV MAVEN_HOME /opt/maven
ENV PATH $MAVEN_HOME/bin:$PATH

# Install Ant 1.10.1
RUN echo "Install Ant 1.10.1"  && \
    wget http://mirrors.dcarsat.com.ar/apache/ant/binaries/apache-ant-1.10.1-bin.tar.gz && \
    tar -zxf apache-ant-1.10.1-bin.tar.gz && \
    mv apache-ant-1.10.1 /opt/ant && \
    rm -rf apache-ant-1.10.1-bin.tar.gz
ENV ANT_HOME /opt/ant
ENV PATH $ANT_HOME/bin:$PATH

# Install Python
ENV PYTHON_VERSION 2.7.14
ENV PYTHON_PIP_VERSION 9.0.1
RUN apt-get update && \
    apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev zlib1g-dev && \
    wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" && \
    mkdir -p /usr/src/python && \
	tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz && \
	rm python.tar.xz && \
    cd /usr/src/python && \
    ./configure --enable-shared --enable-unicode=ucs4 && \
    make && \
    make install && \
    ldconfig && \
    wget -O /tmp/get-pip.py 'https://bootstrap.pypa.io/get-pip.py' && \
    python2 /tmp/get-pip.py "pip==$PYTHON_PIP_VERSION" && \
    rm /tmp/get-pip.py && \
    pip install --no-cache-dir --upgrade --force-reinstall "pip==$PYTHON_PIP_VERSION" && \
    rm -rf /usr/src/python ~/.cache
COPY pip_requirements.txt /usr/local/bin/pip_requirements.txt
RUN pip install -r /usr/local/bin/pip_requirements.txt

# Install Node.js 8.5.0
RUN wget https://nodejs.org/dist/v8.5.0/node-v8.5.0-linux-x64.tar.xz && \
    tar -xJf node-v8.5.0-linux-x64.tar.xz -C /usr/local --strip-components=1 && \
    rm node-v8.5.0-linux-x64.tar.xz

# Install Sonar Runner 2.4
RUN echo "Install Sonar Runner 2.4" && \
    wget http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist/2.4/sonar-runner-dist-2.4.zip && \
    unzip sonar-runner-dist-2.4.zip && \
    mv sonar-runner-2.4 /opt/sonar-runner && \
    rm -rf sonar-runner-dist-2.4.zip && \
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
ENV JENKINS_SWARM_VERSION 3.4
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-jar-with-dependencies.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar && \
    chmod 755 /usr/share/jenkins && \
    chmod +x /usr/local/bin/start_slave.sh

# Switch to Jenkins Slave user
USER jenkins-slave

# Copying default Maven Settings
COPY settings.xml /home/jenkins-slave/.m2/settings.xml

#Entrypoint
ENTRYPOINT ["/usr/local/bin/start_slave.sh"]
