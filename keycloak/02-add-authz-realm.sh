keycloak_pod=$(kubectl get po -l app=keycloak -o custom-columns=:metadata.name)
keycloak_pod=`echo $keycloak_pod | xargs`
echo $keycloak_pod

kubectl cp keycloak/authz-realm.json $keycloak_pod:/tmp
kubectl exec -ti $keycloak_pod -- /bin/bash -c "cd ~/keycloak/bin; chmod +x kcadm.sh"
kubectl exec -ti $keycloak_pod -- /bin/bash -c "~/keycloak/bin/kcadm.sh config credentials --server http://keycloak.keycloak:8080/auth --realm master --user admin --password admin"
kubectl exec -ti $keycloak_pod -- /bin/bash -c "~/keycloak/bin/kcadm.sh create realms -s realm=authz -s enabled=true"
kubectl exec -ti $keycloak_pod -- /bin/bash -c "~/keycloak/bin/kcadm.sh create partialImport -r authz -s ifResourceExists=FAIL -o -f /tmp/authz-realm.json"