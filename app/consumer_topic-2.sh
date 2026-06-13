#!/bin/bash

COUNT=10 #количество сообщений


echo "========================================="
echo "Начало чтения сообщений из topic-2"
echo "========================================="

kafka-console-consumer.sh \
  --bootstrap-server "${SERVER}:19192" \
  --topic topic-2 \
  --group unit5 \
  --from-beginning \
  --consumer.config consumer.properties \
  --max-messages $COUNT \
  --property print.key=true \
  --property key.separator=" -> " \
  --property value.deserializer=org.apache.kafka.common.serialization.StringDeserializer

echo "========================================="
echo "Завершено чтение сообщений из topic-2"
echo "========================================="
