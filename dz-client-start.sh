#! /bin/bash

cd /home/test/kafka
bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic connect-test --from-beginning
