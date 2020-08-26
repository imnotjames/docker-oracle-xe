FROM oraclelinux:7-slim

ARG ORACLE_XE_RPM=/tmp/oracle-database-xe-18.rpm
ARG ORACLE_XE_RPM_URL=https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-18c-1.0-1.x86_64.rpm

ENV ORACLE_PASSWORD=oracle

ENV ORAENV_ASK=NO
ENV ORACLE_DOCKER_INSTALL=true
ENV ORACLE_SID=XE
ENV ORACLE_BASE=/opt/oracle
ENV ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE

# Do in a separate step to allow caching for development.
# However, we MUST use the squash feature of docker to squish
# the layers together OR move this into the install script
# RUN curl -fL ${ORACLE_XE_RPM_URL} -o ${ORACLE_XE_RPM}
# RUN yum install -y ${ORACLE_XE_RPM}

COPY install.sh /
RUN /bin/bash /install.sh

COPY configure.sh /
RUN /bin/bash /configure.sh && \
    tar -Pczf /oradata.tgz ${ORACLE_BASE}/oradata/ && \
    rm -rf ${ORACLE_BASE}/oradata/

COPY start.sh shutdown.sh check.sh /

RUN chmod a+x /*.sh

EXPOSE 1521

VOLUME [ "${ORACLE_BASE}/oradata" ]

HEALTHCHECK --interval=1m --start-period=2m --retries=10 \
  CMD /check.sh

CMD exec /start.sh
