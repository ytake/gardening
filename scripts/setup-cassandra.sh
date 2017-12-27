#!/usr/bin/env bash

SELF_IP=`ifconfig enp0s8 | awk '/inet / {print $2}'`

sudo mv /etc/cassandra/default.conf/cassandra.yaml /etc/cassandra/conf/cassandra.yaml
sudo sed -i "s|seeds: \"127.0.0.1\"|seeds: \"$SELF_IP\"|g" /etc/cassandra/conf/cassandra.yaml
sudo sed -i "s|listen_address: localhost|listen_address: $SELF_IP|g" /etc/cassandra/conf/cassandra.yaml
sudo sed -i "s|rpc_address: localhost|rpc_address: $SELF_IP|g" /etc/cassandra/conf/cassandra.yaml
sudo sed -i "s|start_rpc: false|start_rpc: true|g" /etc/cassandra/conf/cassandra.yaml

sudo systemctl enable cassandra
sudo systemctl start cassandra
