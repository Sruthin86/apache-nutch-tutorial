FROM solr:8.11.2

USER root

RUN apt update && \
    apt-get install vim -y && \
    apt-get install links -y && \
    apt clean

USER $SOLR_USER
