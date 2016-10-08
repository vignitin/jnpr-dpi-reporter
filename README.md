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

**Modifying the index:**
Once the index is configured, the received DPI IPFIX records can be visualized in Kibana. For some of the visualizations to work correctly, two of the index fields need to be modified and a new scripted field needs to be added.

1) Modifying the 'netflow.uplinkOctets' and 'netflowdownlinkOctets' fields:
The 'netflow.uplinkOctets' and 'netflowdownlinkOctets' fields specify the number of uplink and downlink Octets consumed by a subscriber. For better visualization of the octets consumed, change the format of these fields in the index to 'Bytes'. To modify the fields, go to 'Settings' \> 'Indices' \> logstash-netflow\* and click on the field to be modified. An example for the netflow.downlinkOctets is shown below:

![Kibana-downlinkOctets](/images/kibana-downlinkOctets.png "Kibana-downlinkOctets")

![Kibana-downlinkOctets-Bytes](/images/kibana-downlinkOctets-Bytes.png "Kibana-downlinkOctets-Bytes")

2) Adding the 'totalOctets' Scripted field:
In order to generate visualizations on total uplink and downlink Octets consumed by a subscriber, a new scripted field called 'totalOctets' is created. To create a Scripted field, go to 'Settings' \> 'Indices' \> logstash-netflow\* \> 'scripted fields' tab, then click on 'Add Scripted Field':

![Kibana-ScriptedField-initial](/images/kibana-ScriptedField-initial.png "Kibana-ScriptedField-initial")

Name the new field as 'totalOctets', specify the format as 'Bytes', enter the enter the below formula in the script tab and click 'update field':
```
doc['netflow.downlinkOctets'].value + doc['netflow.uplinkOctets'].value
```

![Kibana-ScriptedField-totalOctets](/images/kibana-ScriptedField-totalOctets.png "Kibana-ScriptedField-totalOctets")

That's it! The visualizations and dashboard in the container should work fine now.

