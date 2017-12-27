#!/usr/bin/env bash

SELF_IP=`ifconfig enp0s8 | awk '/inet / {print $2}'`

# for Kafka Client
sudo echo "
advertised.listeners=PLAINTEXT://$SELF_IP:9092
" >> /etc/kafka/server.properties

# for Apache Zookeeper
sudo sed -i "s|zookeeper.connect=localhost:2181|zookeeper.connect=$SELF_IP:2181|g" /etc/kafka/server.properties

sudo confluent start

# optional
# nohup /home/vagrant/trifecta-ui/bin/trifecta-ui -Dhttp.port=9888 > /var/log/trifecta/out.log &

