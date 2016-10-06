# Dockerfile for Juniper jflow-reporter based on ELK stack
# Uses Elasticsearch 2.4.0, Logstash 2.4.0, Kibana 4.6.0
##{PENDING} Add cronjob for Geo-ip data

# Build with:
# docker build -t vignitin/jflow-reporter .

# Run with:
# docker run -p 5601:5601 -p 9200:9200 -p 2055:2055/udp -p 4739:4739/udp -v /Users/nitinvig/Scripting/Projects/jflow-data/elasticsearch:/var/lib/elasticsearch -it --name jflowrep_con vignitin/jflow-reporter

FROM phusion/baseimage
MAINTAINER Nitin Vig <vignitin@gmail.com>


###############################################################################
#                                INSTALLATION
###############################################################################

### install prerequisites (wget)

ARG DEBIAN_FRONTEND=noninteractive
RUN set -x \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends ca-certificates wget \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get clean \
 && set +x

### Install Elasticsearch

RUN wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
RUN set -x \
 && apt-get update -qq \
 && apt-get install -qqy \
		elasticsearch \
		openjdk-8-jdk \
 && apt-get clean \
 && set +x

### Install Logstash

RUN echo "deb http://packages.elastic.co/logstash/2.4/debian stable main" | tee -a /etc/apt/sources.list
RUN set -x \
 && apt-get update -qq \
 && apt-get install -qqy logstash \
 && apt-get clean \
 && set +x

# Logstash Geo-IP data
RUN set -x \
 && cd /etc/logstash \
 && wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz \
 && wget http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz \
 && gunzip GeoLiteCity.dat.gz \
 && gunzip GeoIPASNum.dat.gz \
 && set +x


### Install Kibana

ENV KIBANA_HOME /opt/kibana

RUN echo "deb http://packages.elastic.co/kibana/4.6/debian stable main" | tee -a /etc/apt/sources.list
RUN set -x \
 && apt-get update -qq \
 && apt-get install -qqy kibana \
 && apt-get clean \
 && set +x

# Install Kibana plugins
RUN set -x \
 && ${KIBANA_HOME}/bin/kibana plugin --install elastic/sense \
 && ${KIBANA_HOME}/bin/kibana plugin -i tagcloud -u https://github.com/stormpython/tagcloud/archive/master.zip \
 && ${KIBANA_HOME}/bin/kibana plugin -i prelert_swimlane_vis -u https://github.com/prelert/kibana-swimlane-vis/archive/v0.1.0.tar.gz \

# && ${KIBANA_HOME}/bin/kibana plugin -i heatmap -u https://github.com/stormpython/heatmap/archive/master.zip \
# && ${KIBANA_HOME}/bin/kibana plugin -i vectormap -u https://github.com/stormpython/vectormap/archive/master.zip \
# && ${KIBANA_HOME}/bin/kibana plugin -i elastic/timelion \
 && set +x

# Kibana - Sankey plugin pre-requisites (nodejs, npm, git, nodejs-legacy)
RUN set -x \
 && apt-get update -qq \
 && apt-get -qqy install \
 nodejs \
 npm \
 git \
 nodejs-legacy \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && set +x

# Kibana - Sankey plugin
RUN set -x \
 && cd /tmp \
 && git clone https://github.com/chenryn/kbn_sankey_vis.git \
 && cd kbn_sankey_vis \
 && npm install \
 && npm run build \
 && cp -R build/kbn_sankey_vis ${KIBANA_HOME}/installedPlugins/ \
 && rm -rf ..\kbn_sankey_vis \
 && set +x

RUN chown -R kibana:kibana /opt/kibana

###############################################################################
#                               CONFIGURATION
###############################################################################

### configure Elasticsearch
ADD docker/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

### configure Logstash
# Updated IPFIX codec for Juniper DPI
ADD docker/logstash/ipfix.yaml /opt/logstash/vendor/bundle/jruby/1.9/gems/logstash-codec-netflow-2.1.1/lib/logstash/codecs/netflow/ipfix.yaml

# Updated struct.rb file to fix duplicate fields error
ADD docker/logstash/struct.rb /opt/logstash/vendor/bundle/jruby/1.9/gems/bindata-2.3.1/lib/bindata/struct.rb

# filters
ADD docker/logstash/logstash-jflow.conf /etc/logstash/conf.d/logstash-jflow.conf

### configure Kibana
ADD docker/kibana/kibana.yml /opt/kibana/config/kibana.yml
ADD docker/kibana/dashboard.json /opt/kibana/dashboard.json
ADD docker/kibana/visualization.json /opt/kibana/visualization.json


### configure logrotate

#ADD ./elasticsearch-logrotate /etc/logrotate.d/elasticsearch
#ADD ./logstash-logrotate /etc/logrotate.d/logstash
#ADD ./kibana-logrotate /etc/logrotate.d/kibana
#RUN chmod 644 /etc/logrotate.d/elasticsearch \
# && chmod 644 /etc/logrotate.d/logstash \
# && chmod 644 /etc/logrotate.d/kibana


###############################################################################
#                                   START
###############################################################################

ADD docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 5601 9200 9300 4739 2055
VOLUME /var/lib/elasticsearch

CMD [ "/usr/local/bin/start.sh" ]
