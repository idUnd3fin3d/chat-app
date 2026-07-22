#!/bin/bash

IMAGE_REF=$(cat image_ref)

if [ $ENV == "dev" ]; then
  K8S_REPLICAS_COUNT=$K8S_REPLICAS_COUNT_DEV
else
  K8S_REPLICAS_COUNT=$K8S_REPLICAS_COUNT_PROD
fi

if kubectl get deployment $SERVICE_NAME > /dev/null 2>&1; then
  kubectl set image deployment/${SERVICE_NAME} app=${IMAGE_REF}
  kubectl scale --replicas=${K8S_REPLICAS_COUNT} deployment/${SERVICE_NAME}
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
  kubectl ingress-rule set $K8S_INGRESS_NAME --host $SERVICE_DOMAIN --path "/" --path-type "prefix" --service $SERVICE_NAME --port 80 --tls $K8S_TLS_SECRET_NAME
else
  cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${K8S_INGRESS_NAME}
  annotations:
    nginx.ingress.kubernetes.io/proxy-read-timeout: '3600'
    nginx.ingress.kubernetes.io/proxy-send-timeout: '3600'
    nginx.ingress.kubernetes.io/proxy-connect-timeout: '3600'

    nginx.ingress.kubernetes.io/proxy-buffering: 'off'
    nginx.ingress.kubernetes.io/proxy-request-buffering: 'off'

    nginx.ingress.kubernetes.io/ssl-redirect: 'true'
    nginx.ingress.kubernetes.io/force-ssl-redirect: 'true'

    nginx.ingress.kubernetes.io/limit-rps: '10'
    nginx.ingress.kubernetes.io/limit-connections: '100'

    nginx.ingress.kubernetes.io/limit-req-status-code: '429'
    nginx.ingress.kubernetes.io/limit-conn-status-code: '429'
spec:
  ingressClassName: nginx
  tls:
    - secretName: ${K8S_TLS_SECRET_NAME}
      hosts:
        - ${SERVICE_DOMAIN}
  rules:
    - host: ${SERVICE_DOMAIN}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ${SERVICE_NAME}
                port:
                  number: 80
EOF
fi

kubectl rollout status -w deployment/${SERVICE_NAME}