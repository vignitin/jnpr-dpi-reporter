jnpr-dpi-reporter: Data visualization tool for Juniper MX-based DPI
==================

**jnpr-dpi-reporter** is a containerized data visualization tool for Juniper MX-based DPI devices. 

The Juniper MX-based Services Control Gateway (SCG) when configured as a DPI, exports information about the subscriber flows in the IPFIX format (RFC 7011). Along with the standard netflow fields, export IPFIX records also include Juniper enterprise-specific Information Elements that provide more detailed information about the flows. These records can be consumed by an IPFIX collector and fed into a data visualization tool.

In the jnpr-dpi-reported docker container is based on the ELK stack and the netflow codec in the logstash collector has been modified to support the Juniper enterprise-specific Information Elements. To get things started, a few Kibana plugins, visualizations and a Summary dashboard have also been included in this container.

The container also be used for visualizing any netflow version 5, 9 and 10 records. It listens on the following ports:
- Netflow v5,9: **2055/udp**
- Netflow v10: **4739/udp**

The following ELK versions have been used:
- Logstash (collector): 2.4
- Elasticsearch (database/search engine): 2.4
- Kibana (front-end): 2.6.1

Pre-requisites:
---------------
The requirements is to have docker installed on your localhost. Docker installation instructions can be found here: https://docs.docker.com/engine/installation/



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
Detailed description: https://github.com/vignitin/jnpr-dpi-reporter

![Kibana-ScriptedField-totalOctets](/images/kibana-ScriptedField-totalOctets.png "Kibana-ScriptedField-totalOctets")

That's it! The visualizations and dashboard in the container should work as expected now.
