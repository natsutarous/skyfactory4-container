FROM eclipse-temurin:8u352-b08-jre-jammy as base
RUN addgroup --gid 1001 skyfactory && adduser --disabled-password --home=/skyfactory --uid 1001 --gid 1001 skyfactory

########### 
# Install some additional dependencies.
# See pom.xml for more detail
FROM maven:3.8.6-eclipse-temurin-8-focal as pom
WORKDIR /
COPY build/pom/pom.xml /pom.xml
RUN mvn dependency:copy-dependencies

###########
# download and unpack SkyFactory-4
FROM base as installer
RUN apt update && \
    apt install -y unzip wget && \
    wget -c https://edge.forgecdn.net/files/3565/687/SkyFactory-4_Server_4_2_4.zip -O SkyFactory_4_Server.zip && \
    unzip SkyFactory_4_Server.zip -d /tmp/skyfactory && \
    cd /tmp/skyfactory && bash -x /tmp/skyfactory/Install.sh

########### 
# Merge additional dependencies into SkyFactory 4 
FROM installer as merged-installer

COPY --from=pom /target/dependency /tmp/dependency
# Replace log4j-core-2.15.0 to log4j-core-2.16.0
# See CVE-2021-44832
RUN cp /tmp/dependency/log4j-core-2.16.0.jar /tmp/skyfactory/libraries/org/apache/logging/log4j/log4j-core/2.15.0/log4j-core-2.15.0.jar

###########
# Setup container image
FROM base
ENV SERVER_JAR=forge-1.12.2-14.23.5.2860.jar
WORKDIR /skyfactory

# EULA Agreement / Create a save directory
RUN echo eula=true > /skyfactory/eula.txt && mkdir /skyfactory/world && chown -R skyfactory:skyfactory /skyfactory/

# Copy SkyFactory 4 from installer
COPY --from=merged-installer --chown=skyfactory:skyfactory /tmp/skyfactory/config /skyfactory/config
COPY --from=merged-installer --chown=skyfactory:skyfactory /tmp/skyfactory/fontfiles /skyfactory/fontfiles
COPY --from=merged-installer --chown=skyfactory:skyfactory /tmp/skyfactory/libraries /skyfactory/libraries
COPY --from=merged-installer --chown=skyfactory:skyfactory /tmp/skyfactory/mods /skyfactory/mods
COPY --from=merged-installer --chown=skyfactory:skyfactory /tmp/skyfactory/oresources /skyfactory/oresources
COPY --from=merged-installer --chown=skyfactory:skyfactory /tmp/skyfactory/resources /skyfactory/resources
COPY --from=merged-installer --chown=skyfactory:skyfactory /tmp/skyfactory/scripts /skyfactory/scripts
COPY --from=merged-installer --chown=skyfactory:skyfactory /tmp/skyfactory/forge-1.12.2-14.23.5.2860.jar /skyfactory/$SERVER_JAR
COPY --from=merged-installer --chown=skyfactory:skyfactory /tmp/skyfactory/minecraft_server.1.12.2.jar /skyfactory/minecraft_server.1.12.2.jar 
COPY --from=merged-installer --chown=skyfactory:skyfactory /tmp/skyfactory/server-icon.png   /skyfactory/server-icon.png
COPY --from=merged-installer --chown=skyfactory:skyfactory /tmp/skyfactory/server.properties /skyfactory/server.properties.original

# Copy Entrypoint from local
COPY --chown=skyfactory:skyfactory build/skyfactory/entrypoint.sh /skyfactory/entrypoint.sh

# Runtime user = skyfactory
USER skyfactory

# Boot SkyFactory 4 server
ENTRYPOINT ["/bin/bash", "-x", "/skyfactory/entrypoint.sh"]

# Metadata
LABEL maintainer="natsutarous@"
EXPOSE 25565
VOLUME [ "/skyfactory/world" ]
