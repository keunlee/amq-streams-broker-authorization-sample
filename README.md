# Kafka + Keycloak + LDAP: Broker Authorization Sample

This use case demonstrates the following features: 

- TLS OAuth2.0 Authentication with Kafka
- TLS OAuth2.0 Authorization with Kafka
- Keycloak and LDAP User/Group integration
- Kafka Broker Authorization using Keycloak 

Do the following: 

- Do either step I or step II (depending on the cluster type you are targeting - i.e. Vanilla Kubernetes orOpenshift)
- Do step III
- Do step IV

# I. [Kubernetes Setup and Deployment](k8s/README.md)

# II. [Openshift 4.9.x Setup and Deployment](ocp/README.md)

# III. [LDAP Setup](docs/LDAP-SETUP.md)

# IV. [Kafka Broker Authorization Test](docs/OAUTH-TEST.md)

## Testing Authorization Rules for Admin Group Policy

Follow the comments in the script below: 

```bash
# switch to the `clients` namespace
kubens clients

# check the running pods
# you should see a single running pod: kafka-client-shell
kubectl get po

# terminal into the pod
kubectl exec -it kafka-client-shell -- /bin/bash
```

From this point on, you will be terminaled into the pod. Continue to follow the script:  

Setup your TLS environment:

```bash
# set up your TLS environment
export PASSWORD=truststorepassword
export KAFKA_OPTS=" \
  -Djavax.net.ssl.trustStore=/opt/kafka/certificates/kafka-client-truststore.p12 \
  -Djavax.net.ssl.trustStorePassword=$PASSWORD \
  -Djavax.net.ssl.trustStoreType=PKCS12"
```

Add your token endpoint to the environment: 

```bash
# add TOKEN ENDPOINT to env
export TOKEN_ENDPOINT=https://keycloak.keycloak:8443/auth/realms/kafka-authz/protocol/openid-connect/token
```

Create JWT for the user "kermit"

```bash
# generate an oauth2 jwt and validate the token - make sure you're not getting back gibberish - user kermit
REFRESH_TOKEN=$(~/bin/oauth.sh -q kermit) # password: pass
~/bin/jwt.sh $REFRESH_TOKEN
```

Generate oauth user properties for "kermit"

```bash
# generate oauth user properties - kermit
cat > ~/kermit.properties << EOF
security.protocol=SASL_SSL
sasl.mechanism=OAUTHBEARER
sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required \
  oauth.refresh.token="$REFRESH_TOKEN" \
  oauth.client.id="kafka-cli" \
  oauth.token.endpoint.uri="https://keycloak.keycloak:8443/auth/realms/kafka-authz/protocol/openid-connect/token" ;
sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler
EOF
```

Using the oauth properites file we created, this will allow "kermit" to produce messages on the topic "my-topic". 

Go ahead and generate some messages then hit ctrl-c to exit. 

```bash
# kermit produces messages on "my-topic"
bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap.kafka:9093 --topic my-topic --producer.config ~/kermit.properties
```

Generate an oauth2 jwt and validate the token - make sure you're not getting back gibberish - user fozzie

```bash
# generate an oauth2 jwt and validate the token - make sure you're not getting back gibberish - user fozzie
REFRESH_TOKEN=$(~/bin/oauth.sh -q fozzie) # password: pass
~/bin/jwt.sh $REFRESH_TOKEN
```

Generate oauth user properties for "fozzie"

```bash
# generate oauth user properties - fozzie
cat > ~/fozzie.properties << EOF
security.protocol=SASL_SSL
sasl.mechanism=OAUTHBEARER
sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required \
  oauth.refresh.token="$REFRESH_TOKEN" \
  oauth.client.id="kafka-cli" \
  oauth.token.endpoint.uri="https://keycloak.keycloak:8443/auth/realms/kafka-authz/protocol/openid-connect/token" ;
sasl.login.callback.handler.class=io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler
EOF
```

Using the oauth properites file we created, this will allow "fozzie" to consume messages on the topic "my-topic". 

You should see messages that "kermit" produced earlier. hit ctrl-c to exit. 

```bash
# fozzie consumes messages that kermit produced
bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap.kafka:9093 --topic my-topic  --from-beginning --consumer.config ~/fozzie.properties
```

Follow along in the asciinema recording below: 

[![asciicast](https://asciinema.org/a/vLmnBu6NagKAfdwnmoi7pkwDG.svg)](https://asciinema.org/a/vLmnBu6NagKAfdwnmoi7pkwDG)

# Sources

- https://www.janua.fr/mapping-ldap-group-and-roles-to-redhat-sso-keycloak/
- https://www.keycloak.org/docs/6.0/server_admin/
- https://robferguson.org/blog/2019/12/29/angular-openid-connect-keycloak/
- https://robferguson.org/blog/2020/01/03/keycloak-flowable-and-openldap/
- https://robferguson.org/blog/2019/01/28/how-to-flowable-and-ldap/
- http://www.mastertheboss.com/jboss-frameworks/keycloak/keycloak-oauth2-example-with-rest-application
- https://strimzi.io/docs/operators/latest/full/using.html#assembly-oauth-authentication_str
- https://strimzi.io/docs/operators/latest/full/using.html#assembly-oauth-authorization_str
- https://strimzi.io/blog/2019/10/25/kafka-authentication-using-oauth-2.0/
- https://github.com/strimzi/strimzi-kafka-oauth/blob/master/examples/README-authz.md
- https://github.com/strimzi/strimzi-kafka-oauth#building
