FROM apache/nutch:release-1.19

# This config file adds the user agent for the crawl
COPY conf/nutch-site.xml /root/nutch_source/conf/nutch-site.xml

RUN apk update && \
    apk add vim && \
    apk add links && \
    mkdir -p  /root/nutch_source/urls

# The seeds file is a list of url's, one on each line
COPY urls/seed.txt /root/nutch_source/urls/seed.txt

