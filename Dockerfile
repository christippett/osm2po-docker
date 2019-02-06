FROM alpine
RUN apk --update add unzip openssl wget && rm -rf /var/cache/apk/*
RUN wget -q -P /tmp https://osm2po.de/releases/osm2po-5.2.43.zip && \
    unzip /tmp/osm2po-5.2.43.zip -d /tmp/osm2po
RUN wget -q -P /data http://download.geofabrik.de/australia-oceania/new-zealand-latest.osm.pbf

FROM openjdk:11-jre-slim
WORKDIR /usr/src/osm2po
COPY --from=0 /tmp/osm2po /usr/src/osm2po
COPY --from=0 /data /data
COPY osm2po/* /usr/src/osm2po/
RUN ["java", \
    "-Xmx6g", \
    "-jar", \
    "osm2po-core-5.2.43-signed.jar", \
    "prefix=nz", \
    "tileSize=x", \
    "cmd=tjspg", \
    "postp.0.class=de.cm.osm2po.plugins.postp.PgRoutingWriter", \
    "/data/new-zealand-latest.osm.pbf"]

FROM openjdk:11-jre-slim
WORKDIR /usr/src/osm2po
COPY --from=1 /usr/src/osm2po .
EXPOSE 8080
CMD ["java", \
    "-Xmx6g", \
    "-jar", \
    "osm2po-core-5.2.43-signed.jar", \
    "prefix=nz", \
    "tileSize=x", \
    "cmd=r"]
