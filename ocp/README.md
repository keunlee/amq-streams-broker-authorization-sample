# Openshift 4.9.x Setup and Deployment

# Prerequisites

The following are necessary to proceed with the setup of this demonstration: 

- An accessible Kubernetes Cluster with sufficient privileges (i.e. K3D, Kind, Vanilla k8s)
- Kubernetes cluster Load Balancers must be deployed/enabled (i.e. metallb, traefik, cloud load balancers, etc.)
- Make sure the following are installed and added to your PATH: 
    - [kubectx/kubens](https://github.com/ahmetb/kubectx)
    - [openshift client tools - oc](https://github.com/openshift/origin/releases)
    - [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
    - [python client for openshift - requires python](https://pypi.org/project/openshift/)
    - python
    - openssl
    - keytool

# Setup

The infrastructure to be created will consist of the following components: 

- [OpenLDAP](https://www.openldap.org/) - An LDAP Server for managing LDAP groups and users
- [Red Hat SSO](https://access.redhat.com/products/red-hat-single-sign-on) - Keycloak SSO Server
- [Red Hat AMQ Streams](https://www.redhat.com/en/resources/amq-streams-datasheet) - Kafka

> You will need to have the following namespaces available for use in this demo:

```
openldap
kafka
keycloak
```

To install an entire ready-made infrastructure: 

```bash
# change directory into ocp directory
cd ocp

# execute the bash install script
./install.sh

# execute the bash cleanup script to remove
/.cleanup.sh
```