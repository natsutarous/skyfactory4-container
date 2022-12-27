SkyFactory 4 Container
===

[SkyFactory 4](https://www.curseforge.com/minecraft/modpacks/skyfactory-4) is one of the best Minecraft modpacks. "SkyFactory for Container" is a OCI container image which you can launch a SkyFactory 4 Multi-Player server with.
This container image allows you to start a Skyfactory 4 server on any OCI container runtime like Docker, Podman, also Kubernetes!

## Usage

```bash
# Docker
$ docker run -td --name myskyfactory -p 25565:25565 ghcr.io/natsutarous/skyfactory4:4.2.4.latest

# Podman
$ podman run -td --name myskyfactory -p 25565:25565 ghcr.io/natsutarous/skyfactory4:4.2.4.latest

# Kubernetes
$ kubectl create -f k8s/simple
```

You can configure your Skyfactory 4 server adding the properties to the container.

#### Configuring Skyfactory itself.
Official documentation: https://github.com/DarkPacks/SkyFactory-4/wiki/Multiplayer-Instructions

Administrators of Skyfactory 4 server may want to configure world-type, islands and etc. Please pass your configuration property file `server.properties` to the inside of the container `/skyfactory/server.properties`. The container entrypoint will check if there is a file `/skyfactory/server.properties`, if no the entrypoint will generate a default property.

```bash
# Example
$ docker run -td -v myserver.properties:/skyfactory/server.properties -p 25565:25565 ghcr.io/natsutarous/skyfactory4:4.2.4.latest
```

#### Configuring the JVM
Minecraft loves JVM. You may want to configure the JVM options. This container image has some predefined environment variables. See belows.

- MIN_RAM: default `2g`
    - This value will be passed to the JVM option `-Xms`
- MAX_RAM: default `2g`
    - This value will be passed to the JVM option `-Xmx`
- JAVA_OPTS: default ``
- OVERRIDE_DEFAULT_JAVA_OPTS: default `-XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M -Dfml.readTimeout=180 -XX:+UseContainerSupport`
