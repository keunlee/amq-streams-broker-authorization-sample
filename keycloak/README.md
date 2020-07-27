# Keycloak

## Generate Certs for TLS

```bash
# create CA key
openssl genrsa -out ca.key 2048

# create CA certificate
openssl req -x509 -new -nodes -sha256 -days 3650 -subj "/CN=example.com" \
  -key ca.key -out ca.crt

# create keycloak server private key
openssl genrsa -out keycloak.key 2048

# create certificate-signing request
openssl req -new -sha256 \
  -key keycloak.key \
  -subj "/CN=keycloak" \
  -reqexts SAN \
  -config ssl.cnf \
  -out keycloak.csr

# Generate the final keycloak certificate, signed by CA
openssl x509 -req -extfile ssl.cnf -extensions SAN -in keycloak.csr -CA ca.crt \
  -CAkey ca.key -CAcreateserial -out keycloak.crt -days 365 -sha256
```

## Deploy Keycloak

```bash
kubectl create ns keycloak

kubectl create secret tls tls-keys -n keycloak --cert=./keycloak.crt --key=./keycloak.key

kubens keycloak

kubectl create -f keycloak.yaml
```

## Create an `authz` Keycloak Realm

1) create a new realm w/in keycloak, name it: "authz"
2) import the `authz-realm.json` file into the newly created keycloak realm

```bash
kcadm.sh config credentials --server http://keycloak.keycloak:8080/auth --realm master --user admin --password admin
kubectl exec -ti keycloak-69689547-zkctk -- /bin/bash -c "cd ~/keycloak/bin; chmod +x kcadm.sh"
kubectl exec -ti keycloak-69689547-zkctk -- /bin/bash -c "~/keycloak/bin/kcadm.sh config credentials --server http://keycloak.keycloak:8080/auth --realm master --user admin --password admin"
kubectl exec -ti keycloak-69689547-zkctk -- /bin/bash -c "~/keycloak/bin/kcadm.sh create realms -s realm=authz -s enabled=true"
kubectl exec -ti keycloak-69689547-zkctk -- /bin/bash -c "~/keycloak/bin/kcadm.sh create partialImport -r authz -s ifResourceExists=FAIL -o -f authz-realm.json"
```