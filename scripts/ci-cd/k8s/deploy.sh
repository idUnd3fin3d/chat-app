#!/bin/bash

IMAGE_REF=$(cat image_ref)

if kubectl get deployment $SERVICE_NAME > /dev/null 2>&1; then
  kubectl set image deployment/${SERVICE_NAME} app=${IMAGE_REF}
  kubectl rollout status -w deployment/${SERVICE_NAME}
else
  cat <<EOF | kubectl apply -f -
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: ${SERVICE_NAME}
  spec:
    replicas: ${K8S_REPLICAS_COUNT}
    selector:
      matchLabels:
        app: ${SERVICE_NAME}
    template:
      metadata:
        labels:
          app: ${SERVICE_NAME}
      spec:
        imagePullSecrets:
          - name: ${K8S_DOCKER_REGISTRY_SECRET_NAME}
        containers:
          - name: app
            image: ${IMAGE_REF}
            ports:
              - containerPort: 80
EOF
fi

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}
spec:
  selector:
    app: ${SERVICE_NAME}
  ports:
    - name: http
      port: 80
      targetPort: 80
  type: ClusterIP
EOF

if kubectl get ingress $K8S_INGRESS_NAME > /dev/null 2>&1; then
  kubectl ingress-rule set $K8S_INGRESS_NAME --host $SERVICE_DOMAIN --path "/" --path-type "prefix" --service $SERVICE_NAME --port 80
else
  kubectl create ingress $K8S_INGRESS_NAME --rule="${SERVICE_DOMAIN}/*=${SERVICE_NAME}:80"
fi