FROM ubuntu:xenial
MAINTAINER Julian Nonino <noninojulian@outlook.com>

# Install Required Tools
# sudo, wget, curl, net-tools, unzip, build-essential, git, subversion and checkinstall
RUN apt-get update && \
    apt-get install -y sudo wget curl net-tools unzip build-essential git subversion checkinstall && \
    rm -rf /var/lib/apt/lists/*

# Install Java 8 JDK Update 121
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz && \
    tar -zxf jdk-8u121-linux-x64.tar.gz -C /opt && \
    ln -s /opt/jdk1.8.0_121/bin/java /usr/bin/java && \
    ln -s /opt/jdk1.8.0_121/bin/javac /usr/bin/javac && \
    rm -rf jdk-8u121-linux-x64.tar.gz
ENV JAVA_HOME /opt/jdk1.8.0_121

# Install Maven 3.5.0
RUN wget http://apache.mirrors.lucidnetworks.net/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz && \
    tar -zxf apache-maven-3.5.0-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.5.0/bin/mvn /usr/bin/mvn && \
    rm -rf apache-maven-3.5.0-bin.tar.gz
ENV MAVEN_HOME /opt/apache-maven-3.5.0

# Install Ant 1.10.1
RUN wget http://mirrors.sonic.net/apache//ant/binaries/apache-ant-1.10.1-bin.tar.gz && \
    tar -zxf apache-ant-1.10.1-bin.tar.gz -C /opt && \
    ln -s /opt/apache-ant-1.10.1/bin/ant /usr/bin/ant && \
    rm -rf apache-ant-1.10.1-bin.tar.gz
ENV ANT_HOME /opt/apache-ant-1.10.1

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

# Install default Python PIP dependencies
COPY pip_requirements.txt /usr/local/bin/pip_requirements.txt
RUN pip install -r /usr/local/bin/pip_requirements.txt

# Set PATH environment variable adding installed tools
ENV PATH $JAVA_HOME/bin:$MAVEN_HOME/bin:$ANT_HOME/bin:$PATH

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
ENV JENKINS_SWARM_VERSION 3.3
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-jar-with-dependencies.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar && \
    chmod 755 /usr/share/jenkins && \
    chmod +x /usr/local/bin/start_slave.sh

# Switch to Jenkins Slave user
USER jenkins-slave

# Copying default Maven Settings
COPY settings.xml /home/jenkins-slave/.m2/settings.xml

#Entrypoint
ENTRYPOINT ["/usr/local/bin/start_slave.sh"]
