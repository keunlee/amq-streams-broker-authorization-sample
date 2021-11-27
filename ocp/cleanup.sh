oc -n kafka delete kafka --all
oc -n kafka delete kafkatopics --all
oc -n kafka delete subscriptions amq-streams
oc -n kafka delete operatorgroups kafka-operatorgroup
oc delete project kafka

oc -n keycloak delete keycloakrealms --all
oc -n keycloak delete keycloak --all
oc -n keycloak delete subscriptions rhsso-operator
oc -n keycloak delete operatorgroups keycloak-rhsso-operatorgroup
oc delete project keycloak

oc delete project openldap

rm -rf bootstrap/roles/ocp4-install-rh-amqstreams/files/out