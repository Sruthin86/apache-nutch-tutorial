FROM apache/nutch:release-1.19

COPY conf/nutch-site.xml /root/nutch_source/conf/nutch-site.xml

RUN apk update && \
    apk add vim && \
    apk add links && \
    mkdir -p  /root/nutch_source/urls

COPY urls/seed.txt /root/nutch_source/urls/seed.txt

