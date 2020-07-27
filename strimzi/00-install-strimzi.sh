kubectl create ns kafka
kubens kafka

curl -L https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.18.0/strimzi-cluster-operator-0.18.0.yaml \
  | sed 's/namespace: .*/namespace: kafka/' \
  | kubectl apply -f - -n kafka

kubectl wait --for=condition=Available  --timeout=180s deployment.apps/strimzi-cluster-operator