kubens default
kubectl delete ns kafka
kubectl delete ns clients
kubectl delete ns keycloak
kubectl delete ns openldap

rm *.crt
rm *.csr
rm *.p12
rm *.cnf
rm *.srl
rm *.key