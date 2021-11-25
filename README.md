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
- Do optional step V

# I. [Kubernetes Setup and Deployment](k8s/README.md)

# II. [Openshift 4.9.x Setup and Deployment](ocp/README.md)

# III. [LDAP Setup](docs/LDAP-SETUP.md)

# IV. [Kafka Broker Authorization Setup and Test](docs/KAFKA-OAUTH-TEST.md)

# V. [Adding Additional Auth Resources](docs/KEYCLOAK-AUTH-RESOURCES.md)

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
