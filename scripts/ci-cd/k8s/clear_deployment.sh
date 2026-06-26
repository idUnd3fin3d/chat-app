#!/bin/bash

kubectl ingress-rule delete $K8S_INGRESS_NAME --service $SERVICE_NAME

kubectl delete service $SERVICE_NAME
kubectl delete deployment $SERVICE_NAME
