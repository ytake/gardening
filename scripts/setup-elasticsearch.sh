#!/usr/bin/env bash

# changed cluster name
sudo sed -i "s/#cluster.name: my-application/cluster.name: gardening/g" /etc/elasticsearch/elasticsearch.yml

/bin/systemctl enable elasticsearch && /bin/systemctl daemon-reload && /bin/systemctl restart elasticsearch
