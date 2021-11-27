oc -n kafka delete "$(oc api-resources --namespaced=true --verbs=delete -o name | tr "\n" "," | sed -e 's/,$//')" --all
oc -n keycloak delete "$(oc api-resources --namespaced=true --verbs=delete -o name | tr "\n" "," | sed -e 's/,$//')" --all

oc delete project openldap
oc delete project keycloak
oc delete project kafka

rm -rf bootstrap/roles/ocp4-install-rh-amqstreams/files/out