keycloak_pod=$(kubectl get po -l app=keycloak -o custom-columns=:metadata.name)
keycloak_pod=`echo $keycloak_pod | xargs`
echo $keycloak_pod

kubectl cp keycloak/kafka-authz-realm.json $keycloak_pod:/tmp
realm=kafka-authz

kubectl exec -ti $keycloak_pod -- /bin/bash -c "cd ~/keycloak/bin; chmod +x kcadm.sh"
kubectl exec -ti $keycloak_pod -- /bin/bash -c "~/keycloak/bin/kcadm.sh config credentials --server http://keycloak.keycloak:8080/auth --realm master --user admin --password admin"
kubectl exec -ti $keycloak_pod -- /bin/bash -c "~/keycloak/bin/kcadm.sh create realms -s realm=$realm -s enabled=true"

kubectl cp keycloak/10-kafka-authz-realm.json $keycloak_pod:/tmp
kubectl cp keycloak/11-kafka-authz-realm.json $keycloak_pod:/tmp
kubectl cp keycloak/12-kafka-authz-realm.json $keycloak_pod:/tmp

kubectl exec -ti $keycloak_pod -- /bin/bash -c "~/keycloak/bin/kcadm.sh create partialImport -r $realm -s ifResourceExists=SKIP -o -f /tmp/10-kafka-authz-realm.json"
kubectl exec -ti $keycloak_pod -- /bin/bash -c "~/keycloak/bin/kcadm.sh create partialImport -r $realm -s ifResourceExists=SKIP -o -f /tmp/11-kafka-authz-realm.json"
kubectl exec -ti $keycloak_pod -- /bin/bash -c "~/keycloak/bin/kcadm.sh create partialImport -r $realm -s ifResourceExists=SKIP -o -f /tmp/12-kafka-authz-realm.json"
