#!/bin/sh

##### Default JVM options
# from SkyFactory "ServerStart.sh"
DEFAULT_JAVA_OPTS=""
DEFAULT_JAVA_OPTS=$DEFAULT_JAVA_OPTS" -XX:+UseG1GC"
DEFAULT_JAVA_OPTS=$DEFAULT_JAVA_OPTS" -Dsun.rmi.dgc.server.gcInterval=2147483646"
DEFAULT_JAVA_OPTS=$DEFAULT_JAVA_OPTS" -XX:+UnlockExperimentalVMOptions"
DEFAULT_JAVA_OPTS=$DEFAULT_JAVA_OPTS" -XX:G1NewSizePercent=20"
DEFAULT_JAVA_OPTS=$DEFAULT_JAVA_OPTS" -XX:G1ReservePercent=20"
DEFAULT_JAVA_OPTS=$DEFAULT_JAVA_OPTS" -XX:MaxGCPauseMillis=50"
DEFAULT_JAVA_OPTS=$DEFAULT_JAVA_OPTS" -XX:G1HeapRegionSize=32M"
DEFAULT_JAVA_OPTS=$DEFAULT_JAVA_OPTS" -Dfml.readTimeout=180"

# For container support
DEFAULT_JAVA_OPTS=$DEFAULT_JAVA_OPTS" -XX:+UseContainerSupport"
# Java 8 does not support MaxRAMPercentage option. Ignore it.
# DEFAULT_JAVA_OPTS=$DEFAULT_JAVA_OPTS" -XX:+MaxRAMPercentage=75"

##### Replace server.properties
if [ ! -f "server.properties" ]; then
	cp server.properties.original server.properties
fi

##### Build JAVA_OPTS
JAVA_OPTS=${OVERRIDE_DEFAULT_JAVA_OPTS:-$DEFAULT_JAVA_OPTS}" "$JAVA_OPTS
MIN_RAM=${MIN_RAM:-2g}
MAX_RAM=${MAX_RAM:-2g}
# The environment variable `SERVER_JAR` is defined in Dockerfile.

##### Launch Server
ENTRYPOINT="java -server -Xms${MIN_RAM} -Xmx${MAX_RAM} ${JAVA_OPTS} -jar ${SERVER_JAR} nogui"
echo "Launching Sky Factory 4 Server..."
echo $ENTRYPOINT
$ENTRYPOINT
