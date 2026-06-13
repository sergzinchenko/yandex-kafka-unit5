echo "========================================="
echo "Начало конфигурирования Kafka-кластера   "
echo "========================================="

cd  ./1
echo "1. Загрузка .env"
set -a
source .env
set +a

echo "2. Создадим приватные ключи и запросы на сертификат (CSR)"
openssl req -new -newkey rsa:2048 -keyout kafka-1.key -out kafka-1.csr -config kafka-1.cnf  -nodes
openssl req -new -newkey rsa:2048 -keyout kafka-2.key -out kafka-2.csr -config kafka-1.cnf  -nodes
openssl req -new -newkey rsa:2048 -keyout kafka-3.key -out kafka-3.csr -config kafka-3.cnf  -nodes


echo "3. Создадим сертификаты брокера, подписанные CA"
openssl x509 -req -days 3650 -in kafka-1.csr  -CA ./ca/ca.crt  -CAkey ./ca/ca.key -CAcreateserial -out kafka-1.crt -extfile kafka-1.cnf -extensions v3_req
openssl x509 -req -days 3650 -in kafka-2.csr  -CA ./ca/ca.crt  -CAkey ./ca/ca.key -CAcreateserial -out kafka-2.crt -extfile kafka-2.cnf -extensions v3_req
openssl x509 -req -days 3650 -in kafka-3.csr  -CA ./ca/ca.crt  -CAkey ./ca/ca.key -CAcreateserial -out kafka-3.crt -extfile kafka-3.cnf -extensions v3_req

echo "4. #Создадим PKCS12-хранилища с сертификатом для каждого брокера с паролем ${PASSWORD}"
openssl pkcs12 -export -in kafka-1.crt -inkey kafka-1.key -chain  -CAfile ./ca/ca.pem  -name kafka-1 -out kafka-1.p12 -password pass:${PASSWORD}
openssl pkcs12 -export -in kafka-2.crt -inkey kafka-2.key -chain  -CAfile ./ca/ca.pem  -name kafka-2 -out kafka-2.p12 -password pass:${PASSWORD}
openssl pkcs12 -export -in kafka-3.crt -inkey kafka-3.key -chain  -CAfile ./ca/ca.pem  -name kafka-3 -out kafka-3.p12 -password pass:${PASSWORD}

echo "5. Создадим truststore для каждого брокера c паролем ${PASSWORD}:"
keytool -import -file ./ca/ca.crt -alias ca -keystore kafka-1.truststore.jks -storepass ${PASSWORD} -noprompt
keytool -import -file ./ca/ca.crt -alias ca -keystore kafka-1.truststore.jks -storepass ${PASSWORD} -noprompt
keytool -import -file ./ca/ca.crt -alias ca -keystore kafka-1.truststore.jks -storepass ${PASSWORD} -noprompt

echo "6. Создадим файлы с паролями:"
echo ${PASSWORD} > kafka-1_sslkey_creds
echo ${PASSWORD} > kafka-1_keystore_creds
echo ${PASSWORD} > kafka-1_truststore_creds
echo ${PASSWORD} > kafka-2_sslkey_creds
echo ${PASSWORD} > kafka-2_keystore_creds
echo ${PASSWORD} > kafka-2_truststore_creds
echo ${PASSWORD} > kafka-3_sslkey_creds
echo ${PASSWORD} > kafka-3_keystore_creds
echo ${PASSWORD} > kafka-3_truststore_creds


echo "7. Импортируем PKCS12 в JKS:"
keytool -importkeystore -srckeystore kafka-1.p12 -srcstoretype PKCS12 -srcstorepass ${PASSWORD} -destkeystore kafka-1.keystore.jks -deststoretype JKS -deststorepass ${PASSWORD}
keytool -importkeystore -srckeystore kafka-2.p12 -srcstoretype PKCS12 -srcstorepass ${PASSWORD} -destkeystore kafka-2.keystore.jks -deststoretype JKS -deststorepass ${PASSWORD}
keytool -importkeystore -srckeystore kafka-3.p12 -srcstoretype PKCS12 -srcstorepass ${PASSWORD} -destkeystore kafka-3.keystore.jks -deststoretype JKS -deststorepass ${PASSWORD}

echo "8. Импортируем CA в Truststore:"
keytool -import -trustcacerts -file ./ca/ca.crt -keystore kafka-1.truststore.jks -storepass ${PASSWORD} -noprompt -alias ca
keytool -import -trustcacerts -file ./ca/ca.crt -keystore kafka-2.truststore.jks -storepass ${PASSWORD} -noprompt -alias ca
keytool -import -trustcacerts -file ./ca/ca.crt -keystore kafka-3.truststore.jks -storepass ${PASSWORD} -noprompt -alias ca

echo "9. Копировние необходимых файлов для docker в рабочую папку"
cp ./*creds ../
cp ./*.jks ../
cp ./kafka-1.truststore.jks  ../client.truststore.jks 

echo "10. Конфигурирование и запуск docker composer"
cd ../
docker compose up -d
sleep 3 #Пауза 3 секунды

echo "========================================="
echo "Кластер Kafka готов работе"
echo "========================================="

