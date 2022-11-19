#!/bin/bash
set -e

echo "PROJECT_ID: ${PROJECT_ID}"

docker build -t python-ping-api . --platform linux/amd64
docker tag python-ping-api:latest gcr.io/${PROJECT_ID}/python-ping-api:latest
docker push gcr.io/${PROJECT_ID}/python-ping-api:latest

docker run -it -p 8000:8000 gcr.io/${PROJECT_ID}/python-ping-api:latest

curl http://127.0.0.1:8000
