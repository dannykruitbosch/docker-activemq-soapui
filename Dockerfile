FROM rmohr/activemq:5.14.4-alpine

USER root
ENV MOCK_SERVICE_PORT=8888 \
    MOCK_SERVICE_NAME=default-mock \
    HOME=/home/soapui \
    SOAPUI_DIR=/home/soapui/SoapUI-5.4.0 \
    SOAPUI_PRJ=/home/soapui/soapui-prj

RUN adduser -D -h /home/soapui soapui soapui && \
    apk --update add --virtual build-dependencies curl && \
    curl -k -O https://s3.amazonaws.com/downloads.eviware/soapuios/5.4.0/SoapUI-5.4.0-linux-bin.tar.gz && \
    tar -xzf SoapUI-5.4.0-linux-bin.tar.gz -C /home/soapui && \
    rm -f SoapUI-5.4.0-linux-bin.tar.gz && \
    cp $ACTIVEMQ_HOME/activemq-all-*.jar $SOAPUI_DIR/lib && \
    chown -R soapui:soapui /home/soapui && \
    find /home/soapui -type d -exec chmod 770 {} \; && \
    find /home/soapui -type f -exec chmod 660 {} \; && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/*

COPY docker-entrypoint.sh /
COPY activemq/activemq.xml $ACTIVEMQ_HOME/conf/activemq.xml
ADD docker-entrypoint-init.d /docker-entrypoint-init.d
ADD soapui-prj $SOAPUI_PRJ

# FIX ALL ACCESS RIGHT ETC
RUN chmod 700 /docker-entrypoint.sh && \
    chmod 770 $SOAPUI_DIR/bin/*.sh && \
    chown -R soapui:soapui $SOAPUI_PRJ && \
    find $SOAPUI_PRJ -type d -exec chmod 770 {} \; && \
    find $SOAPUI_PRJ -type f -exec chmod 660 {} \;

EXPOSE $MOCK_SERVICE_PORT
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start-mock"]