# jnpr-dpi-reporter
Data visualization for Juniper MX-based DPI using ELK stack

**jnpr-dpi-reporter** is a containerized data visualization tool for Juniper MX-based DPI devices. The Juniper MX-based Services Control Gateway (SCG) when used as a DPI exports flow information in the IPFIX format (RFC 7011). The IPFIX records include Juniper enterprise-specific Information Elements to provide detailed information about the flows.

This container is based on an ELK stack. The logstash netflow codec has been modified to support IPFIX records from Juniper MX-based SCG DPI. To get things started, a few Kibana plugins, visualizations and a Summary dashboard have been included in the container. 

The container also be used for visualizing any netflow version 5, 9 and 10 records. It listens on the following ports:
- Netflow v5,9: **2055/udp**
- Netflow v10: **4739/udp**

### Pre-requisites
The requirements is to have docker and docker-compose installed on your host. Docker installation instructions can be found here: https://docs.docker.com/engine/installation/

### Installation
To install the jnpr-dpi-reporter container, you can either be pull it directly from the Docker hub or use this git repository to build it from scratch:

Docker container: https://hub.docker.com/r/vignitin/jnpr-dpi-reporter/

To pull the container from Docker hub:
>
```
docker pull vignitin/jnpr-dpi-reporter
```

To build the container from this git repository:

> Download or clone the git repository:
```
git clone 
```
> Change to the directory
```
cd jnpr-dpi-reporter
```

> Build the docker container
```
docker build -t vignitin/jnpr-dpi-reporter .
```

## Run the container:

> Create a directory on your localhost to map the volume from the container:
```
mkdir /data/elasticsearch
```

> Use the following command to run the container:
```
docker run -p 5601:5601 -p 9200:9200 -p 2055:2055/udp -p 4739:4739/udp -v data/elasticsearch:/var/lib/elasticsearch -it --name jdpirep_con vignitin/jnpr-dpi-reporter
```

### Post-installation configuration:
