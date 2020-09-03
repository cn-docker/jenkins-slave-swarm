#!/usr/bin/env bash

PARAMS=""

# The complete target Jenkins URL like 'http://server:8080/jenkins/'. If this option is specified, auto-discovery will be skipped
if [[ "$@" != *"-master "* ]] && [ ! -z "$JENKINS_MASTER" ]; then
	PARAMS="$PARAMS -master $JENKINS_MASTER"
fi

# Setting defauls Username and Passwords
PARAMS="$PARAMS -username jenkins -password jenkins"

# If the executors param is not specified, set to 1 executor by default
if [[ "$@" != *"-executors "* ]]; then
	PARAMS="$PARAMS -executors 1"
fi

# Worker Label
PARAMS="$PARAMS -labels ubuntu-worker"

exec java $JAVA_OPTS -jar /usr/share/jenkins/swarm-client-jar-with-dependencies.jar -fsroot $HOME $PARAMS "$@"
