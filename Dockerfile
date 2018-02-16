FROM openjdk:8-jdk-slim

ENV GERRIT_HOME /home/gerrit
ENV GERRIT_SITE /home/gerrit/site
ENV GERRIT_LIB ${GERRIT_SITE}/lib
ENV GERRIT_TMP_DIR /home/tmp
ENV GERRIT_TMP_LIB ${GERRIT_TMP_DIR}/lib
ENV GERRIT_USER gerrit
ENV GERRIT_WAR gerrit.war
ENV GERRIT_VERSION 2.11

ARG BOUNCY_CASTLE_BASE_URL=http://central.maven.org/maven2/org/bouncycastle
ARG BOUNCY_CASTLE_VERSION=1.56

RUN apt-get update && apt-get install -y --no-install-recommends \
                                    vim-tiny \
                                    git      \
                                    curl     \
                                    && rm -rf /var/lib/apt/lists/*

# Add user gerrit & group like also gerrit to sudo to allow the gerrit user to issue a sudo cmd
RUN groupadd $GERRIT_USER && \
    useradd -r -u 1000 -g $GERRIT_USER $GERRIT_USER

RUN mkdir ${GERRIT_HOME}

# Download Gerrit
ADD http://gerrit-releases.storage.googleapis.com/gerrit-${GERRIT_VERSION}.war ${GERRIT_HOME}/${GERRIT_WAR}

# Copy the files to bin, config & job folders
ADD ./configs ${GERRIT_HOME}/configs
ADD ./job ${GERRIT_HOME}/job
ADD ./bin ${GERRIT_HOME}/bin
RUN chmod +x ${GERRIT_HOME}/bin/conf-and-run-gerrit.sh

# Add gerrit libs, including bouncy castle for improve ssh security
ADD ${BOUNCY_CASTLE_BASE_URL}/bcpkix-jdk15on/${BOUNCY_CASTLE_VERSION}/bcpkix-jdk15on-${BOUNCY_CASTLE_VERSION}.jar ${GERRIT_TMP_LIB}/bcpkix-jdk15on-${BOUNCY_CASTLE_VERSION}.jar
ADD ${BOUNCY_CASTLE_BASE_URL}/bcprov-jdk15on/${BOUNCY_CASTLE_VERSION}/bcprov-jdk15on-${BOUNCY_CASTLE_VERSION}.jar ${GERRIT_TMP_LIB}/bcprov-jdk15on-${BOUNCY_CASTLE_VERSION}.jar

# Copy the plugins
ADD ./plugins ${GERRIT_HOME}/plugins

WORKDIR ${GERRIT_HOME}

EXPOSE 8080 29418
CMD ["/home/gerrit/bin/conf-and-run-gerrit.sh"]
