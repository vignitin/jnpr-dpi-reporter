# jflow-reporter
Netflow data visualization for Juniper devices using ELK stack

This repo used a modified ELK stack to provide netflow data visualization for Juniper devices. It supports Netflow version 5, 9, & IPFIX. The netflow codec has been modified specifically to support IPFIX records from Juniper Service Control Gateway's (SCG) DPI function.

This container exposes the following ports:
Netflow v5,9: 2055/udp
Netflow v10: 4739/udp

To build the repo:
docker build -t vignitin/jflow-reporter .


To run this repo:
docker run -p 5601:5601 -p 9200:9200 -p 2055:2055/udp -p 4739:4739/udp -v <local host>/<directory>:/var/lib/elasticsearch -it --name jflowrep_con vignitin/jflow-reporter

