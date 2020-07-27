# Strimzi + Keycloak + LDAP: Broker Authorization Use Case

This use case demonstrates the following features: 

- TLS OAuth2.0 Authentication with Kafka
- TLS OAuth2.0 Authorization with Kafka
- Keycloak and LDAP User/Group integration
- Kafka Broker Authorization using Keycloak 

## Prerequisites

- kubernetes cluster
  - Load Balancers must be deployed/enabled (i.e. metallb, traefik, etc.)
- [kubectx/kubens](https://github.com/ahmetb/kubectx)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm 3](https://helm.sh/docs/intro/install/)

## Infastructure

The infrastructure to be created will consist of the following components: 

- OpenLDAP
- 

NOTE: you will need to have the following namespaces available for use in this demo. 

```
openldap
kafka
clients
```

to install an entire ready made infrastructure: 

```bash
./setup.sh
```

# Importing LDAP Users and Groups into Keycloak

TODO

# Broker Authorization Rules in Keycloak

## Consumer Topic Authorization

TODO

## Producer Topic Authorization

TODO

## Consumer Cluster Authorization

TODO

## Production Cluster Authorization

TODO


