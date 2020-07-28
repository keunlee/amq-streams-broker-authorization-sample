```bash

# install kafka operator
kubectl apply -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka

# Let’s use a Bash feature that allows us to by-pass history if prefixing command with a space:

export HISTCONTROL=ignorespace

# Now, let’s create a secret:

export BROKER_SECRET=<SECRET_FOR_KAFKA_BROKER_FROM_KEYCLOAK_CONSOLE>
kubectl create secret generic broker-oauth-secret -n kafka \
  --from-literal=secret=$BROKER_SECRET

# We also need to provide a truststore for TLS connectivity to Keycloak - as a Secret.

kubectl create secret generic ca-truststore --from-file=./ca.crt -n kafka
```



# Configuration application client pods

```bash
# send and recieve messages

kubectl run kafka-producer -ti --image=strimzi/kafka:0.18.0-kafka-2.5.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap.kafka:9092 --topic my-topic


kubectl run kafka-consumer -ti --image=strimzi/kafka:0.18.0-kafka-2.5.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap.kafka:9092 --topic my-topic --from-beginning

# this will fail as expected
kubectl -n clients run kafka-producer -ti --rm=true --restart=Never \
 --image=strimzi/kafka:0.18.0-kafka-2.5.0 -- bin/kafka-console-producer.sh \
   --broker-list my-cluster-kafka-bootstrap.kafka:9093 --topic my-topic

# this will fail as expected
kubectl -n clients run kafka-producer -ti --rm=true --restart=Never \
  --image=strimzi/kafka:0.18.0-kafka-2.5.0 -- bin/kafka-console-producer.sh \
    --broker-list my-cluster-kafka-bootstrap.kafka:9093 --topic my-topic \
    --producer-property 'security.protocol=SSL'

# NOTE: do this everytime you recreate the cluster!!
kubectl get secret my-cluster-cluster-ca-cert -n kafka -o yaml \
  | grep ca.crt | awk '{print $2}' | base64 --decode > kafka.crt

export PASSWORD=truststorepassword
keytool -keystore kafka-client-truststore.p12 -storetype PKCS12 -alias ca \
  -storepass $PASSWORD -keypass $PASSWORD -import -file ca.crt -noprompt
keytool -keystore kafka-client-truststore.p12 -storetype PKCS12 -alias kafka \
  -storepass $PASSWORD -keypass $PASSWORD -import -file kafka.crt -noprompt

kubectl create secret generic kafka-client-truststore -n clients \
  --from-file=./kafka-client-truststore.p12

```

# now

```
kubectl exec -n clients -ti kafka-client-shell /bin/bash
```

```bash
export OAUTH_CLIENT_ID=kafka-producer
export OAUTH_CLIENT_SECRET=3f669dcb-8eaa-431c-8209-716895e1431e
export PASSWORD=truststorepassword
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
  
bin/kafka-console-producer.sh --broker-list \
  my-cluster-kafka-bootstrap.kafka:9093 --topic my-topic \
  --producer-property 'security.protocol=SASL_SSL' \
  --producer-property 'sasl.mechanism=OAUTHBEARER' \
  --producer-property 'sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required;' \
  --producer-property 'sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler' 

export OAUTH_CLIENT_ID=kafka-consumer
export OAUTH_CLIENT_SECRET=84cfc9fa-a372-49ea-8e1d-ec03819a2360
export PASSWORD=truststorepassword
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
  
bin/kafka-console-consumer.sh --bootstrap-server \
  my-cluster-kafka-bootstrap.kafka:9093 --topic my-topic --from-beginning \
  --consumer-property 'security.protocol=SASL_SSL' \
  --consumer-property 'sasl.mechanism=OAUTHBEARER' \
  --consumer-property 'sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required;' \
  --consumer-property 'sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler'
```

# later

```
my-cluster-kafka-bootstrap.kafka.svc:9093

export OAUTH_CLIENT_ID=kafka-producer \
export OAUTH_CLIENT_SECRET=afca7049-ea32-49b3-8b28-59ef9b3b81ec \
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"

bin/kafka-console-producer.sh --broker-list \
  my-cluster-kafka-bootstrap.kafka:9093 --topic my-topic \
  --producer-property 'security.protocol=SASL_SSL' \
  --producer-property 'sasl.mechanism=OAUTHBEARER' \
  --producer-property 'sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required;' \
  --producer-property 'sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler' 

bin/kafka-console-consumer.sh --bootstrap-server \
my-cluster-kafka-bootstrap.kafka.svc:9093 --topic my-topic --from-beginning \
--consumer-property 'security.protocol=SSL'


bin/kafka-console-consumer.sh --bootstrap-server \
  my-cluster-kafka-bootstrap.kafka.svc:9093 --topic my-topic --from-beginning \
  --consumer-property 'security.protocol=SASL_SSL' \
  --consumer-property 'sasl.mechanism=OAUTHBEARER' \
  --consumer-property 'sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required;' \
  --consumer-property 'sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler' 
```

# stuff

```bash
cat > team-a-client.properties << EOF
security.protocol=SASL_PLAINTEXT
sasl.mechanism=OAUTHBEARER
sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required \
  oauth.client.id="team-a-client-alt" \
  oauth.client.secret="3290705d-d7e7-4e84-bca6-52c0c34d0926" \
  oauth.token.endpoint.uri="http://keycloak.keycloak:8080/auth/realms/master/protocol/openid-connect/token" ;
sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler
EOF

cat > team-a-client-ssl.properties << EOF
security.protocol=SASL_SSL
sasl.mechanism=OAUTHBEARER
sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required \
  oauth.client.id="team-a-client-alt" \
  oauth.client.secret="3290705d-d7e7-4e84-bca6-52c0c34d0926" \
  oauth.token.endpoint.uri="https://keycloak.keycloak:8443/auth/realms/master/protocol/openid-connect/token" ;
sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler
EOF
```

```bash
# team-a-client-alt 
export OAUTH_CLIENT_ID=team-a-client-alt \
export OAUTH_CLIENT_SECRET=fb8d822c-c041-4eed-9d2f-3c7e8fc8d3be \
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-producer.sh --broker-list \
  my-cluster-kafka-bootstrap.kafka:9093 --topic a_messages \
  --producer-property 'security.protocol=SASL_SSL' \
  --producer-property 'sasl.mechanism=OAUTHBEARER' \
  --producer-property 'sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required;' \
  --producer-property 'sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler' 

export OAUTH_CLIENT_ID=team-a-client-alt \
export OAUTH_CLIENT_SECRET=fb8d822c-c041-4eed-9d2f-3c7e8fc8d3be \
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-producer.sh --broker-list \
  my-cluster-kafka-bootstrap.kafka:9093 --topic my-topic \
  --producer-property 'security.protocol=SASL_SSL' \
  --producer-property 'sasl.mechanism=OAUTHBEARER' \
  --producer-property 'sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required;' \
  --producer-property 'sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler' 

# plain
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap.kafka:9092 --topic a_messages \
  --producer.config=/home/kafka/team-a-client.properties
  
# ssl
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap.kafka:9093 --topic a_messages \
  --producer.config=/home/kafka/team-a-client-ssl.properties

bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap.kafka:9092 --topic a_messages \
  --producer.config ~/team-a-client.properties
```


# team-a-client kafka-authz

## using environment vars

```bash
# FAIL
export OAUTH_CLIENT_ID=team-a-client \
export OAUTH_CLIENT_SECRET=team-a-client-secret \
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-producer.sh --broker-list \
  my-cluster-kafka-bootstrap.kafka:9093 --topic my-topic \
  --producer-property 'security.protocol=SASL_SSL' \
  --producer-property 'sasl.mechanism=OAUTHBEARER' \
  --producer-property 'sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required;' \
  --producer-property 'sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler' 

# FAIL
export OAUTH_CLIENT_ID=team-a-client \
export OAUTH_CLIENT_SECRET=team-a-client-secret \
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-consumer.sh --bootstrap-server \
  my-cluster-kafka-bootstrap.kafka:9093 --topic my-topic --from-beginning --group a_consumer_group_1 \
  --consumer-property 'security.protocol=SASL_SSL' \
  --consumer-property 'sasl.mechanism=OAUTHBEARER' \
  --consumer-property 'sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required;' \
  --consumer-property 'sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler'

# SUCCESS
export OAUTH_CLIENT_ID=team-a-client \
export OAUTH_CLIENT_SECRET=team-a-client-secret \
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-producer.sh --broker-list \
  my-cluster-kafka-bootstrap.kafka:9093 --topic a_messages \
  --producer-property 'security.protocol=SASL_SSL' \
  --producer-property 'sasl.mechanism=OAUTHBEARER' \
  --producer-property 'sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required;' \
  --producer-property 'sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler' 

# SUCCESS
export OAUTH_CLIENT_ID=team-a-client \
export OAUTH_CLIENT_SECRET=team-a-client-secret \
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-consumer.sh --bootstrap-server \
  my-cluster-kafka-bootstrap.kafka:9093 --topic a_messages --from-beginning --group a_consumer_group_1 \
  --consumer-property 'security.protocol=SASL_SSL' \
  --consumer-property 'sasl.mechanism=OAUTHBEARER' \
  --consumer-property 'sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required;' \
  --consumer-property 'sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler'
```

## using properties file

```bash
cat > ~/team-a-client.properties << EOF
security.protocol=SASL_SSL
sasl.mechanism=OAUTHBEARER
sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required \
  oauth.client.id="team-a-client" \
  oauth.client.secret="team-a-client-secret" \
  oauth.token.endpoint.uri="https://keycloak.keycloak:8443/auth/realms/kafka-authz/protocol/openid-connect/token" ;
sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler
EOF

# PRODUCER - FAILS
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap.kafka:9093 --topic my-topic --producer.config ~/kermit.properties

# CONSUMER - FAILS
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap.kafka:9093 --topic my-topic --from-beginning --consumer.config ~/team-a-client.properties --group a_consumer_group_1

# PRODUCER - SUCCESS
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap.kafka:9093 --topic a_messages --producer.config ~/team-a-client.properties

# CONSUMER - SUCCESS
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap.kafka:9093 --topic a_messages --from-beginning --consumer.config ~/team-a-client.properties --group a_consumer_group_1
```

## administration tools

```bash

# LIST TEAM A'S AUTHORIZED TOPICS
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap.kafka:9093 --command-config ~/team-a-client.properties --list

# LIST TEAM A'S CONSUMER GROUPS IT BELONGS TO
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-consumer-groups.sh --bootstrap-server my-cluster-kafka-bootstrap.kafka:9093 --command-config ~/team-a-client.properties --list
```

## client with different permissions

```bash

cat > ~/team-b-client.properties << EOF
security.protocol=SASL_SSL
sasl.mechanism=OAUTHBEARER
sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required \
  oauth.client.id="team-b-client" \
  oauth.client.secret="team-b-client-secret" \
  oauth.token.endpoint.uri="https://keycloak:8443/auth/realms/kafka-authz/protocol/openid-connect/token" ;
sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler
EOF

# FAILS - NOT AUTHORIZED
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap.kafka:9093 --topic a_messages --producer.config ~/team-b-client.properties

# FAILS - NOT AUTHORIZED -- BECAUSE TEAM B CAN ONLY DO THIS ON ANOTHER CLUSTER
export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap.kafka:9093 --topic b_messages --producer.config ~/team-b-client.properties
```

## power users

```bash

# BOB
REFRESH_TOKEN=$(oauth.sh -q bob)

jwt.sh $REFRESH_TOKEN

cat > ~/bob.properties << EOF
security.protocol=SASL_SSL
sasl.mechanism=OAUTHBEARER
sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required \
  oauth.refresh.token="$REFRESH_TOKEN" \
  oauth.client.id="kafka-cli" \
  oauth.token.endpoint.uri="https://keycloak.keycloak:8443/auth/realms/kafka-authz/protocol/openid-connect/token" ;
sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler
EOF

export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap.kafka:9093 --command-config ~/bob.properties --topic x_messages --create --replication-factor 1 --partitions 1


# PEPE - LDAP - LDAP USER IN SALES GROUP
REFRESH_TOKEN=$(oauth.sh -q pepe)

jwt.sh $REFRESH_TOKEN

cat > ~/pepe.properties << EOF
security.protocol=SASL_SSL
sasl.mechanism=OAUTHBEARER
sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required \
  oauth.refresh.token="$REFRESH_TOKEN" \
  oauth.client.id="kafka-cli" \
  oauth.token.endpoint.uri="https://keycloak.keycloak:8443/auth/realms/kafka-authz/protocol/openid-connect/token" ;
sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler
EOF

export PASSWORD=truststorepassword \
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap.kafka:9093 --command-config ~/pepe.properties --topic x_messages --create --replication-factor 1 --partitions 1
```