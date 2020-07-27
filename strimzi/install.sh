kubectl delete ns kafka
kubectl delete ns clients

sh strimzi/00-install-strimzi.sh
sh strimzi/01-create-broker.sh
sh strimzi/02-create-client.sh

