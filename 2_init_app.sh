#!/bin/bash

echo "================================================="
echo "Начало конфигурирования прикладных ресурсов Kafka"
echo "================================================="


echo "1. Инициализация topic-1"
kafka-topics.sh --create --topic topic-1 --bootstrap-server ${SERVER}:19192 --command-config admin.properties
kafka-acls.sh --authorizer-properties zookeeper.connect=${SERVER}:2181 --add --allow-principal User:producer --operation write --topic topic-1
kafka-acls.sh --authorizer-properties zookeeper.connect=${SERVER}:2181 --add --allow-principal User:producer --operation describe --topic topic-1
kafka-acls.sh --authorizer-properties zookeeper.connect=${SERVER}:2181 --add --allow-principal User:consumer --operation read --topic topic-1
kafka-acls.sh --authorizer-properties zookeeper.connect=${SERVER}:2181 --add --allow-principal User:consumer --operation describe --topic topic-1

echo "2. Инициализация topic-2"
kafka-topics.sh --create --topic topic-2 --bootstrap-server ${SERVER}:19192 --command-config admin.properties
kafka-acls.sh --authorizer-properties zookeeper.connect=${SERVER}:2181 --add --allow-principal User:producer --operation write --topic topic-2
kafka-acls.sh --authorizer-properties zookeeper.connect=${SERVER}:2181 --add --allow-principal User:producer --operation describe --topic topic-2

echo "Настройки ACL"
kafka-acls.sh --authorizer-properties zookeeper.connect=${SERVER}:2181 --list
echo "Топики"
kafka-topics.sh --list --bootstrap-server ${SERVER}:19192 --command-config admin.properties
echo "======================================================================================="
echo "Все готово для запуска приложений Kafka, используйте --bootstrap-server ${SERVER}:19192"
echo "======================================================================================="
