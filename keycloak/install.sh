kubens default
kubectl delete ns keycloak

sh keycloak/00-create-certs.sh
sh keycloak/01-install-keycloak.sh

kubectl wait --for=condition=Available --timeout=180s deployment.apps/keycloak

sh keycloak/02-add-authz-realm.sh