duration=1000 && \
cn=its.project.li && \
NAMESPACE=default && \
mkdir certs
echo ${duration}
echo ${cn}
#Generate a certificate authority certificate and key.
openssl req -new -sha256 -x509 -days ${duration} -nodes -extensions v3_ca -keyout certs/ca.key -out certs/ca.crt -config openssl-with-v3.conf -subj "/CN=${cn}/O=OEM"
#Generate a new key and a certificate signing request to send to the CA.
openssl req -newkey rsa:2048 -nodes -keyout certs/server.key -out certs/server.csr -subj "/CN=${cn}/O=MQTT" #/O=MQTT/C=NO"
#Send the CSR to the CA for signing
openssl x509 -req -sha256 -in certs/server.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/server.crt -days ${duration}
#Generate a new key and certificate signing request to send to the CA.
openssl req -newkey rsa:2048 -nodes -keyout certs/client_key.pem -out certs/client.csr -subj "/CN=${cn}/O=MQTT" #/O=MQTT/C=NO"
#Send the CSR to the CA for signing
openssl x509 -req -sha256 -in certs/client.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/client_crt.pem -days ${duration}
#make a kubernetes secret for the server certificates
kubectl create secret generic mosquitto-certificates --from-file=certs/ca.crt --from-file=certs/server.key --from-file=certs/server.crt
#convert ca.crt to PEM format
openssl x509 -in certs/ca.crt -out certs/ca.pem 
#make kubernetes secret for client
kubectl create secret generic mqtt-client-certificate --from-file=certs/client_crt.pem --from-file=certs/client_key.pem --from-file=certs/ca.pem