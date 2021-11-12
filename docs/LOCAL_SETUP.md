# Local Infrastructure using K3D

The infrastructure to be created will consist of the following components: 

- [OpenLDAP](https://www.openldap.org/) - An LDAP Server for managing LDAP groups and users
- [Keycloak](https://www.keycloak.org/)/[Red Hat SSO](https://access.redhat.com/products/red-hat-single-sign-on) - The **upstream** version of Red Hat SSO
- [Strimzi](https://strimzi.io/)/[Red Hat AMQ Streams](https://www.redhat.com/en/resources/amq-streams-datasheet) Kafka Cluster - The **upstream** version of AMQ Streams

> You will need to have the following namespaces available for use in this demo:

```
openldap
kafka
keycloak
clients
```

To install an entire ready-made infrastructure: 

```bash
./setup.sh
```
