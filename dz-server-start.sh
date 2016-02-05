#! /bin/bash

cd /home/test/kafka
screen -A -D -m "bin/zookeeper-server-start.sh config/zookeeper.properties"
screen -A -D -m "bin/kafka-server-start.sh config/server.properties"
screen -A -D -m "bin/kafka-server-start.sh config/server-1.properties"
screen -A -D -m "bin/kafka-server-start.sh config/server-2.properties"
screen -A -D -m "bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 3 --partitions 1 --topic test"
screen -A -D -m "bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic test"
screen -A -D -m "bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test"
screen -A -D -m "bin/connect-standalone.sh config/connect-standalone.properties \
  config/connect-file-source.properties config/connect-file-sink.properties"
