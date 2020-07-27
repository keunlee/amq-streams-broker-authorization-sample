kubectl delete secret broker-oauth-secret -n kafka
kubectl delete secret ca-truststore -n kafka

export HISTCONTROL=ignorespace
export BROKER_SECRET=kafka-broker-secret
kubectl create secret generic broker-oauth-secret -n kafka --from-literal=secret=$BROKER_SECRET
kubectl create secret generic ca-truststore --from-file=ca.crt -n kafka
kubectl apply -f strimzi/kafka-persistent-single-oauth-authz-alt-2.5.0.yaml -n kafka

sleep 20
kubectl wait --for=condition=Ready --timeout=180s pod/my-cluster-zookeeper-0

sleep 20
kubectl wait --for=condition=Ready --timeout=180s pod/my-cluster-kafka-0

sleep 20
kubectl wait --for=condition=Available  --timeout=360s deployment/my-cluster-entity-operator

