kubens default
kubectl delete ns keycloak

kubectl create ns keycloak
kubens keycloak

sh keycloak/00-create-certs.sh
sh keycloak/01-install-keycloak.sh
sh keycloak/02-add-authz-realm.sh