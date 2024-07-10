FROM docker.io/eclipse-temurin:17-jre-jammy
LABEL maintainer="Axon Ivy AG <info@axonivy.com>"

ARG IVY_ENGINE_DOWNLOAD_URL
ARG IVY_HOME=/usr/lib/axonivy-engine

# Establecer el frontend de debconf para no interactuar
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar el índice de paquetes e instalar apt-utils
RUN apt-get update && \
    apt-get install -y apt-utils wget unzip && \
    rm -rf /var/lib/apt/lists/* && \

# Crear el usuario ivy
    useradd --uid 1000 --user-group --no-create-home ivy && \

# Descargar y descomprimir Ivy Engine
    wget ${IVY_ENGINE_DOWNLOAD_URL} -O /tmp/ivy.zip --no-verbose && \
    unzip /tmp/ivy.zip -d ${IVY_HOME} && \
    rm -f /tmp/ivy.zip && \

# Crear y cambiar permisos de los directorios necesarios
    mkdir ${IVY_HOME}/applications && \
    mkdir ${IVY_HOME}/configuration/applications && \
    chown -R ivy:0 ${IVY_HOME} && \

    mkdir /var/lib/axonivy-engine && \
    ln -s ${IVY_HOME}/applications /var/lib/axonivy-engine/applications && \
    ln -s ${IVY_HOME}/deploy /var/lib/axonivy-engine/deploy && \
    chown -R ivy:0 /var/lib/axonivy-engine && \
    ln -s ${IVY_HOME}/configuration /etc/axonivy-engine && \
    ln -s ${IVY_HOME}/elasticsearch/config /etc/axonivy-engine/elasticsearch && \
    ln -s ${IVY_HOME}/logs /var/log/axonivy-engine && \

# Permitir que el motor se ejecute con usuarios arbitrarios (el grupo necesita tener acceso de escritura)
    chmod -R g=u ${IVY_HOME}

# Añadir y configurar el script de entrada
ADD --chown=ivy:0 ./docker-entrypoint.sh ${IVY_HOME}/bin/docker-entrypoint.sh
RUN chmod ug+x ${IVY_HOME}/bin/docker-entrypoint.sh

# Establecer el directorio de trabajo y el usuario
WORKDIR ${IVY_HOME}
USER 1000

# Exponer el puerto 8080
EXPOSE 8080

# Configurar el punto de entrada
ENTRYPOINT ["/usr/lib/axonivy-engine/bin/docker-entrypoint.sh"]
