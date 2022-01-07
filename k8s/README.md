# Kubernetes Setup and Deployment

# Prerequisites

The following are necessary to proceed with the setup of this demonstration: 

- An accessible Kubernetes Cluster with sufficient privileges (i.e. K3D, Kind, Vanilla k8s)
- Kubernetes cluster Load Balancers must be deployed/enabled (i.e. metallb, traefik, cloud load balancers, etc.)
- Make sure the following are installed and added to your PATH: 
    - [kubectx/kubens](https://github.com/ahmetb/kubectx)
    - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
    - [helm 3](https://helm.sh/docs/intro/install/)
    - [jq](https://stedolan.github.io/jq/)
    - openssl
    - keytool

# Setup

The infrastructure to be created will consist of the following components: 

- [OpenLDAP](https://www.openldap.org/) - An LDAP Server for managing LDAP groups and users
- [Keycloak](https://www.keycloak.org/) - Keycloak SSO Server
- [Strimzi](https://strimzi.io/) - Kafka

> You will need to have the following namespaces available for use in this demo:

```
openldap
kafka
keycloak
```

To install an entire ready-made infrastructure: 

```bash
# change directory into k8s directory
cd k8s

# execute the bash install script
./install.sh

# execute the bash cleanup script to remove
/.cleanup.sh
```