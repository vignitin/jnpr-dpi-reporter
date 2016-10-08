# jnpr-dpi-reporter
Data visualization for Juniper MX-based DPI using ELK stack

**jnpr-dpi-reporter** is a containerized data visualization tool for Juniper MX-based DPI devices. The Juniper MX-based Services Control Gateway (SCG) when used as a DPI exports flow information in the IPFIX format (RFC 7011). The IPFIX records include Juniper enterprise-specific Information Elements to provide detailed information about the flows.

This container is based on an ELK stack. The logstash netflow codec has been modified to support IPFIX records from Juniper MX-based SCG DPI. To get things started, a few Kibana plugins, visualizations and a Summary dashboard have been included in the container. 

The container also be used for visualizing any netflow version 5, 9 and 10 records. It listens the following ports:
- Netflow v5,9: **2055/udp**
- Netflow v10: **4739/udp**

To build the repo:
```
docker build -t vignitin/jnpr-dpi-reporter .
```

To run this repo:
```
docker run -p 5601:5601 -p 9200:9200 -p 2055:2055/udp -p 4739:4739/udp -v <local host>/<directory>:/var/lib/elasticsearch -it --name jdpirep_con vignitin/jnpr-dpi-reporter
```
