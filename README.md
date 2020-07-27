# Strimzi + Keycloak + LDAP: Broker Authorization Use Case

This use case demonstrates the following features: 

- TLS OAuth2.0 Authentication with Kafka
- TLS OAuth2.0 Authorization with Kafka
- Keycloak and LDAP User/Group integration
- Kafka Broker Authorization using Keycloak 

## Prerequisites

make sure you have an accessible kubernetes cluster: 

- kubernetes cluster
  - Load Balancers must be deployed/enabled (i.e. metallb, traefik, etc.)

make sure the following are installed added to your PATH: 

- [kubectx/kubens](https://github.com/ahmetb/kubectx)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm 3](https://helm.sh/docs/intro/install/)

## Infastructure

The infrastructure to be created will consist of the following components: 

- OpenLDAP
- Keycloak/RHSSO
- Strimzi/AMQ Streams Kafka Cluster

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

## Add an LDAP Provider and Import Users

You can access keycloak leveraging a proxy. one way to do to this is via port-forwarding your keycloak pod. 

```bash
# example - accessible at: https://localhost:8443
# obtain keycloak pod name. i.e. keycloak-69689547-fmn6h
kubectl port-forward keycloak-69689547-fmn6h 8443:8443
```

1) Login to the main Keycloak dashboard: `u:admin, p:admin`

2) Select realm: `authz`

3) Select `User Federation` and then `ldap` from the provider drop down

4) Match your screen configuration to the illustration below

![](assets/keycloak-setup-001.png)

We are using OpenLDAP as our LDAP provider in this example, hence the screen configurations will be specific to configuring OpenLDAP. 

Between other LDAP Providers, these configurations will differ. 

5) click `save`, then click `Synchronize all users`

6) validate users imported over from ldap by click on the `users` tab and then clicking on `view all users`

![](assets/keycloak-setup-002.png)

## Import LDAP Groups

1) select `User Federation` and then `ldap` 
2) select `Mappers`
3) click `create` and fill in with the following values: 

![](assets/keycloak-setup-003.png)


4) click `save` and then `Sync LDAP Groups to Keycloak`


# Broker Authorization Rules

The following use cases will demonstrate how to create various broker authorization rules and test them via kafka consumer/producer tools

## Consumer Topic Authorization

TODO

## Producer Topic Authorization

TODO

## Consumer Cluster Authorization

TODO

## Production Cluster Authorization

TODO

# Sources



