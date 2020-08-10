kubectl create secret tls tls-keys -n keycloak --cert=keycloak.crt --key=keycloak.key

kubectl create -f keycloak/keycloak.yaml

kubectl wait --for=condition=Available --timeout=360s deployment.apps/keycloak