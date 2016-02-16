FROM ubuntu:14.04

# File Author / Maintainer
MAINTAINER Jaike Jennison <jjennison@echo360.com>

##
## CONFIGURATION
##

# Setup environment
ENV DEBIAN_FRONTEND noninteractive

# Fix sh
#RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Update sources
RUN apt-get -y update && apt-get -y install \
 ca-certificates \
 curl \
 default-jre \
 git-core \
 screen \
 zookeeperd

# Configure user
RUN groupadd test \
&& useradd test -m -g test -s /bin/bash \
&& passwd -d -u test \
&& echo "test ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/test \
&& chmod 0440 /etc/sudoers.d/test \
&& mkdir /home/test/kafka \
&& chown test:test /home/test/kafka

# Install Kafka
RUN cd /home/test && curl -O http://mirror.symnds.com/software/Apache/kafka/0.9.0.0/kafka_2.11-0.9.0.0.tgz \
 && tar -xvf kafka_2.11-0.9.0.0.tgz -C kafka --strip-components 1

# Configure Kafka Servers & sample log
RUN echo 'broker.id=1 \
Listeners=PLAINTEXT://:9093 \
port=9093 \
num.network.threads=3 \
num.io.threads=8 \
socket.send.buffer.bytes=102400 \
socket.receive.buffer.bytes=102400 \
socket.request.max.bytes=104857600 \
log.dir=/tmp/kafka-logs-1 \
num.partitions=1 \
num.recovery.threads.per.data.dir=1 \
log.retention.hours=168 \
log.segment.bytes=1073741824 \
log.retention.check.interval.ms=300000 \
log.cleaner.enable=false \
zookeeper.connect=localhost:2181 \
zookeeper.connection.timeout.ms=6000' > /home/test/kafka/config/server-1.properties \
&& echo 'broker.id=1 \
Listeners=PLAINTEXT://:9094 \
port=9094 \
num.network.threads=3 \
num.io.threads=8 \
socket.send.buffer.bytes=102400 \
socket.receive.buffer.bytes=102400 \
socket.request.max.bytes=104857600 \
log.dir=/tmp/kafka-logs-2 \
num.partitions=1 \
num.recovery.threads.per.data.dir=1 \
log.retention.hours=168 \
log.segment.bytes=1073741824 \
log.retention.check.interval.ms=300000 \
log.cleaner.enable=false \
zookeeper.connect=localhost:2181 \
zookeeper.connection.timeout.ms=6000' > /home/test/kafka/config/server-2.properties \
&& cd /home/test/kafka && echo '--- \
level: Info \
message: openssl version = OpenSSL 1.0.2d 9 Jul 2015 \
pid: 4896 \
service: Spinner \
type: LogThirdParty \
version: OpenSSL 1.0.2d 9 Jul 2015 \
when: 2016-01-22T20:19:05.977Z \
who: alp-cc-1-PC \
---' > test.txt

# Initalize & Start Servers
RUN cd /home/test \
  && git clone https://github.com/jaikejennison/dz.git \
  && cp /home/test/dz/dz-server-start.sh /home/test/kafka/dz-server-start.sh \
  && cp /home/test/dz/dz-client-start.sh /home/test/kafka/dz-client-start.sh \
  && cd /home/test/kafka && chmod +x dz-server-start.sh && chmod +x dz-client-start.sh \
  && ./dz-server-start.sh

#RUN /etc/init.d/zookeeper start && cd /home/test/kafka && screen -A -D -m "bin/zookeeper-server-start.sh config/zookeeper.properties" \
#&& screen -A -D -m "bin/kafka-server-start.sh config/server.properties" \
#&& screen -A -D -m "bin/kafka-server-start.sh config/server-1.properties" \
#&& screen -A -D -m "bin/kafka-server-start.sh config/server-2.properties" \
#&& screen -A -D -m "bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 3 --partitions 1 --topic test" \
#&& screen -A -D -m "bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic test" \
#&& screen -A -D -m "bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test" \
#&& echo 'message: openssl version = OpenSSL 1.0.2d 9 Jul 2015' > test.txt \
#&& screen -A -D -m "bin/connect-standalone.sh config/connect-standalone.properties config/connect-file-source.properties config/connect-file-sink.properties"

#RUN cd /home/test/kafka && bin/zookeeper-server-start.sh config/zookeeper.properties \
#  | bin/kafka-server-start.sh config/server.properties \
#  | bin/kafka-server-start.sh config/server-1.properties \
#  | bin/kafka-server-start.sh config/server-2.properties \
#  | bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 3 --partitions 1 --topic test \
#  | bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic test \
#  | bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test ^C \
#  | bin/connect-standalone.sh config/connect-standalone.properties config/connect-file-source.properties config/connect-file-sink.properties
#RUN bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic test --from-beginning

##
## ENTRY POINTS
##

#ENTRYPOINT ["/home/test/kafka/bin/zookeeper-server-start.sh", "/home/test/kafka/config/zookeeper.properties"] # Zookeeper

# Kafka
#ENTRYPOINT ["/home/test/kafka/bin/kafka-server-start.sh", "/home/test/kafka/config/server.properties"]
#ENTRYPOINT ["/home/test/kafka/bin/kafka-topics.sh", "--create", "--zookeeper localhost:2181", "--replication-factor 1", "--partitions 1", "--topic test"]
#ENTRYPOINT ["/home/test/kafka/bin/kafka-console-producer.sh", "--broker-list localhost:9092" "--topic test"]
#ENTRYPOINT ["/home/test/kafka/bin/connect-standalone.sh", "/home/test/kafka/config/connect-standalone.properties", "/home/test/kafka/config/connect-file-source.properties", "/home/test/kafka/config/connect-file-sink.properties"]
#ENTRYPOINT ["/home/test/kafka/bin/kafka-console-consumer.sh", "--zookeeper localhost:2181", "--topic connect-test", "--from-beginning"]

##
## COMMANDS
##

#CMD ["/home/test/kafka/bin/zookeeper-server-start.sh", "/home/test/kafka/config/zookeeper.properties"] # Zookeeper

# Kafka
#CMD ["/home/test/kafka/bin/kafka-server-start.sh", "/home/test/kafka/config/server.properties"]
#CMD ["/home/test/kafka/bin/kafka-topics.sh", "--create", "--zookeeper localhost:2181", "--replication-factor 1", "--partitions 1", "--topic test"]
#CMD ["/home/test/kafka/bin/kafka-console-producer.sh", "--broker-list localhost:9092" "--topic test"]
#CMD ["/home/test/kafka/bin/connect-standalone.sh", "/home/test/kafka/config/connect-standalone.properties", "/home/test/kafka/config/connect-file-source.properties", "/home/test/kafka/config/connect-file-sink.properties"]
CMD ["/home/test/kafka/bin/kafka-console-consumer.sh", "--zookeeper localhost:2181", "--topic connect-test", "--from-beginning"]

##
## Change user
##

USER test
WORKDIR /home/test/kafka
#CMD ["/bin/bash"]

##
## Expose
##

##
## The test user's Volume and ports:
## 9000 default, 9999 debug
## 2181 kafka-topics, 9092 kafka-console-producer
##

VOLUME "/home/test/kafka"
EXPOSE 9000
EXPOSE 9999
EXPOSE 2181
EXPOSE 9092
WORKDIR /home/test/kafka
