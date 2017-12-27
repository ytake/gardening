#!/usr/bin/env bash

# changed cluster name
sudo sed -i "s/#cluster.name: my-application/cluster.name: gardening/" /etc/elasticsearch/elasticsearch.yml

