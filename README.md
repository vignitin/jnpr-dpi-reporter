jnpr-dpi-reporter
==================

Open-source data visualization tool for Juniper MX-based DPI

**jnpr-dpi-reporter** is a containerized data visualization tool for Juniper MX-based DPI devices. The Juniper MX-based Services Control Gateway (SCG) when used as a DPI exports flow information in the IPFIX format (RFC 7011). The IPFIX records include Juniper enterprise-specific Information Elements to provide detailed information about the flows.

This container is based on an ELK stack. The logstash netflow codec has been modified to support IPFIX records from Juniper MX-based SCG DPI. To get things started, a few Kibana plugins, visualizations and a Summary dashboard have been included in the container. 

The container also be used for visualizing any netflow version 5, 9 and 10 records. It listens on the following ports:
- Netflow v5,9: **2055/udp**
- Netflow v10: **4739/udp**

The ELK versions used in this container are:
Logstash (collector): 2.4
Elasticsearch (database/search engine): 2.4
Kibana (front-end): 2.6.1

Pre-requisites:
---------------
The requirements is to have docker and docker-compose installed on your host. Docker installation instructions can be found here: https://docs.docker.com/engine/installation/



Installation:
-------------
To install the jnpr-dpi-reporter container, you can either be pull it directly from the Docker hub or use this git repository to build it from scratch:

Docker container: https://hub.docker.com/r/vignitin/jnpr-dpi-reporter/

To pull the container from Docker hub:
```
docker pull vignitin/jnpr-dpi-reporter
```

To build the container from this git repository:

1) Download or clone the git repository:
```
git clone https://github.com/vignitin/jnpr-dpi-reporter.git
```
2) Change to the directory
```
cd jnpr-dpi-reporter
```

3) Build the docker container
```
docker build -t vignitin/jnpr-dpi-reporter .
```


Run the container:
------------------

1) Create a directory on your localhost to map the volume from the container:
```
mkdir /data/elasticsearch
```

2) Use the following command to run the container:
```
docker run -p 5601:5601 -p 9200:9200 -p 2055:2055/udp -p 4739:4739/udp -v /data/elasticsearch:/var/lib/elasticsearch -it --name jdpirep_con vignitin/jnpr-dpi-reporter
```
It takes about 1-2 minutes for all container services to start. Once the services have started, the kibana front-end can be accessed at: http://localhost:5601



Post-installation configuration:
--------------------------------
After installation, the tool will wait to receive netflow data from the network. Once it starts receiving data, a new index pattern needs to be configured in Kibana to start building the visualizations. 

**Configuring the index pattern:**

When you first login to Kibana (http://localhost:5601), you will see the 'Settings' tab where the index needs to be configured. When the tool has not received any data yet, the screen looks as follows: 

![Kibana-initial-screen](/images/kibana-initial-screen.png "Kibana-initial-screen")

Once the tool starts receiving netflow data, the kibana screen will changes as below allowing you to create a new index. Configure a new index pattern here, by entering 'logstash-netflow*' under the 'Index name or pattern' and click 'Create':

![Kibana-index-configuration](/images/kibana-index-config.png "Kibana-index-configuration")

Once the index is configured, the received DPI IPFIX records can be visualized in Kibana.

**Configuring the scripted field:**

ABCD
