#! /bin/bash

WEBHOOK_NS=${1:-"default"}
WEBHOOK_NAME=${2:-"webhook-service"}

# Create certs for our webhook
openssl genrsa -out /tmp/tls.key 2048
openssl req -new -key /tmp/tls.key \
    -subj "/CN=${WEBHOOK_NAME}.${WEBHOOK_NS}.svc" \
    -addext "subjectAltName=DNS:${WEBHOOK_NAME}.${WEBHOOK_NS}.svc,DNS:${WEBHOOK_NAME}.${WEBHOOK_NS}.svc" \
    -out /tmp/tls.csr

openssl x509 -req -extfile <(printf "subjectAltName=DNS:${WEBHOOK_NAME}.${WEBHOOK_NS}.svc,DNS:${WEBHOOK_NAME}.${WEBHOOK_NS}.svc\nbasicConstraints=CA:TRUE") -days 365 -in /tmp/tls.csr -signkey /tmp/tls.key -out /tmp/tls.crt

# Create certs secrets for k8s
kubectl create secret generic \
    {{ include "core-provider.fullname" . }}-certs \
    --from-file=tls.key=/tmp/tls.key \
    --from-file=tls.crt=/tmp/tls.crt


# # Set the CABundle on the webhook registration
CA_BUNDLE=$(base64 -w 0 /tmp/tls.crt)

kubectl create configmap {{ include "core-provider.fullname" . }}-configmap --from-literal={{ include "core-provider.fullname" . }}-mutate.yaml="webhooks:
- name: core.provider.krateo.io
  admissionReviewVersions:
  - v1
  - v1alpha2
  - v1alpha1
  rules:
  - operations: ['CREATE']
    apiGroups: ['composition.krateo.io']
    apiVersions: ['*']
    resources: ['*']
    scope: '*'
  sideEffects: None
  clientConfig:
    service:
      namespace: ${WEBHOOK_NS}
      name: {{ include "core-provider.fullname" . }}-webhook-service
      path: /mutate
      port: 9443
    caBundle: ${CA_BUNDLE}"

rm /tmp/tls.*