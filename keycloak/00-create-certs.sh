# create CA key
openssl genrsa -out ca.key 2048

# create CA certificate
openssl req -x509 -new -nodes -sha256 -days 3650 -subj "/CN=example.com" -key ca.key -out ca.crt

# create keycloak server private key
openssl genrsa -out keycloak.key 2048

# create certificate-signing request
openssl req -new -sha256 \
  -key keycloak.key \
  -subj "/CN=keycloak" \
  -reqexts SAN \
  -config keycloak/ssl.cnf \
  -out keycloak.csr

# Generate the final keycloak certificate, signed by CA
openssl x509 -req -extfile keycloak/ssl.cnf -extensions SAN -in keycloak.csr -CA ca.crt \
  -CAkey ca.key -CAcreateserial -out keycloak.crt -days 365 -sha256