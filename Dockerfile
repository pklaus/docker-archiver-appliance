FROM alpine AS download-extract

RUN apk update && apk add tar unzip curl

WORKDIR /aa
ENV RELEASE=v0.0.1_SNAPSHOT_13-Nov-2019
ENV RELEASE_FILE=archappl_v0.0.1_SNAPSHOT_13-November-2019T15-45-42.tar.gz
RUN curl -OL https://github.com/slacmshankar/epicsarchiverap/releases/download/${RELEASE}/${RELEASE_FILE}
RUN tar -xf ${RELEASE_FILE} && rm ${RELEASE_FILE}
RUN ls
RUN for app in engine mgmt etl retrieval; do \
   echo "extracting $app.war"; \
   unzip -q $app.war -d $app; \
 done
RUN ls *


FROM tomcat:9.0.36-jdk14-openjdk-slim-buster

SHELL ["/bin/bash", "-c"]

COPY --from=download-extract /aa/NOTICE /aa/LICENSE /aa/Apache_2.0_License.txt /aa/RELEASE_NOTES /

COPY --from=download-extract /aa/*.war /usr/local/tomcat/webapps/
# ^ above: put the compressed web application resource (WAR) files into the webapps folder.
#          Tomcat unzips them when starting up.
# v below: already copy unpacked web applications to the webapps folder.
#          This save a bit of time on container startup but results in slightly larger image size:
#COPY --from=download-extract /aa/engine /usr/local/tomcat/webapps/engine
#COPY --from=download-extract /aa/mgmt /usr/local/tomcat/webapps/mgmt
#COPY --from=download-extract /aa/etl /usr/local/tomcat/webapps/etl
#COPY --from=download-extract /aa/retrieval /usr/local/tomcat/webapps/retrieval

COPY etc/archappl/appliances.xml /etc/archappl/
COPY etc/archappl/archappl.properties /etc/archappl/
COPY etc/archappl/policies.py /etc/archappl/
COPY etc/archappl/tomcat_conf_server.xml /etc/archappl
COPY etc/archappl/log4j.properties /etc/archappl/

# Folders we store data and logs in
# (may mount them from the host machine):
RUN mkdir -p /storage/{sts,mts,lts,logs}

RUN ln -s /etc/archappl/log4j.properties /usr/local/tomcat/lib/log4j.properties
RUN mv /usr/local/tomcat/conf/server.xml{,.dist} && ln -s /etc/archappl/tomcat_conf_server.xml /usr/local/tomcat/conf/server.xml
RUN rmdir /usr/local/tomcat/logs && ln -s /storage/logs /usr/local/tomcat/logs

# Be generous with the heap
ENV JAVA_OPTS="-XX:+UseG1GC -Xms4G -Xmx4G -ea"
# Tell the appliance that we are deploying all the components in one VM;
# this reduces the thread count and other parameters in an effort to optimize memory:
ENV ARCHAPPL_ALL_APPS_ON_ONE_JVM=true
ENV ARCHAPPL_APPLIANCES=/etc/archappl/appliances.xml
ENV ARCHAPPL_MYIDENTITY=appliance0
ENV ARCHAPPL_POLICIES=/etc/archappl/policies.py
ENV ARCHAPPL_PROPERTIES_FILENAME=/etc/archappl/archappl.properties
ENV ARCHAPPL_PERSISTENCE_LAYER=org.epics.archiverappliance.config.persistence.InMemoryPersistence
ENV ARCHAPPL_SHORT_TERM_FOLDER=/storage/sts
ENV ARCHAPPL_MEDIUM_TERM_FOLDER=/storage/mts
ENV ARCHAPPL_LONG_TERM_FOLDER=/storage/lts
ENV EPICS_CA_AUTO_ADDR_LIST=yes
ENV EPICS_CA_ADDR_LIST=

EXPOSE 17665

CMD ["catalina.sh", "run"]
