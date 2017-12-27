#!/usr/bin/env bash

/bin/systemctl enable rabbitmq-server
/bin/systemctl restart rabbitmq-server
rabbitmq-plugins enable rabbitmq_management

rabbitmqctl add_user gardening 00:secreT,@
rabbitmqctl set_user_tags gardening administrator
rabbitmqctl set_permissions -p / gardening ".*" ".*" ".*"
