curl -L https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.26.0/strimzi-cluster-operator-0.26.0.yaml \
  | sed 's/namespace: .*/namespace: kafka/' \
  | kubectl delete -f - -n kafka

kubens default
kubectl delete ns kafka
kubectl delete ns keycloak
kubectl delete ns openldap

rm *.crt
rm *.csr
rm *.p12
rm *.cnf
rm *.srl
rm *.key