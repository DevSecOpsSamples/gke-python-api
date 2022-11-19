#!/bin/bash
set -e

echo "PROJECT_ID: ${PROJECT_ID}"

docker build -t python-ping-api . --platform linux/amd64
docker tag python-ping-api:latest gcr.io/${PROJECT_ID}/python-ping-api:latest

gcloud auth configure-docker
docker push gcr.io/${PROJECT_ID}/python-ping-api:latest

kubectl scale deployment python-ping-api --replicas=0
kubectl scale deployment python-ping-api --replicas=3
sleep 3
kubectl get pods -n
