kubectl create ns keycloak

kubectl create secret tls tls-keys -n keycloak --cert=keycloak.crt --key=keycloak.key

kubens keycloak

kubectl create -f keycloak/keycloak.yaml