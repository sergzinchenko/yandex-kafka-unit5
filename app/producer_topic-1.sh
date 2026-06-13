#!/bin/bash

COUNT=10 #количество сообщений

echo "========================================="
echo "Начало отправки сообщений в topic-1"
echo "========================================="

echo "Отправка сообщений в topic-1"
for i in $(seq 1 "$COUNT"); do
    echo "topic-1-item_$i:$(jq -n --arg id "$i" --arg ts "$(date +"%Y%m%d%H%M%S")" '{id: $id, timestamp: $ts}')" | \
    kafka-console-producer.sh \
      --bootstrap-server "$SERVER":19192 \
      --topic topic-1 \
      --producer.config producer.properties \
      --property parse.key=true \
      --property key.separator=:
    echo "Отправлено сообщение $i"
    sleep 1 # Задержка 1 секунда
done
echo "В topic-1 отправлено $COUNT сообщений"

echo "========================================="
echo "Окончание отправки сообщений в topic-1"
echo "========================================="
