# Python sample project for GKE

[![Build](https://github.com/DevSecOpsSamples/gke-python-api/actions/workflows/build.yml/badge.svg)](https://github.com/DevSecOpsSamples/gke-python-api/actions/workflows/build.yml) [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=DevSecOpsSamples_gke-python-api&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=DevSecOpsSamples_gke-python-api) [![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=DevSecOpsSamples_gke-python-api&metric=ncloc)](https://sonarcloud.io/summary/new_code?id=DevSecOpsSamples_gke-python-api)

The sample project to deploy Python REST API application, Service, HorizontalPodAutoscaler, Ingress, and BackendConfig on GKE.

- [app.py](app/app.py)
- [python-ping-api-template.yaml](app/python-ping-api-template.yaml)

---

## Prerequisites

### Installation

- [Install the gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Install kubectl and configure cluster access](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)

### Set environment variables

```bash
PROJECT_ID="sample-project" # replace with your project
COMPUTE_ZONE="us-central1"
```

### Set GCP project

```bash
gcloud config set project ${PROJECT_ID}
gcloud config set compute/zone ${COMPUTE_ZONE}
```

---

## Create a GKE cluster

Create an Autopilot GKE cluster. It may take around 9 minutes.

```bash
gcloud container clusters create-auto sample-cluster --region=${COMPUTE_ZONE}
gcloud container clusters get-credentials sample-cluster
```

---

## Deploy python-ping-api

Build and push to GCR:

```bash
cd ../app
docker build -t python-ping-api . --platform linux/amd64
docker tag python-ping-api:latest gcr.io/${PROJECT_ID}/python-ping-api:latest

gcloud auth configure-docker
docker push gcr.io/${PROJECT_ID}/python-ping-api:latest
```

Create and deploy K8s Deployment, Service, HorizontalPodAutoscaler, Ingress, and GKE BackendConfig using the [python-ping-api-template.yaml](app/python-ping-api-template.yaml) template file.

```bash
sed -e "s|<project-id>|${PROJECT_ID}|g" python-ping-api-template.yaml > python-ping-api.yaml
cat python-ping-api.yaml

kubectl apply -f python-ping-api.yaml
```

It may take around 5 minutes to create a load balancer, including health checking.

Confirm that pod configuration and logs after deployment:

```bash
kubectl logs -l app=python-ping-api

kubectl describe pods

kubectl get ingress python-ping-api-ingress
```

Confirm that response of `/ping` API.

```bash
LB_IP_ADDRESS=$(gcloud compute forwarding-rules list | grep python-ping-api | awk '{ print $2 }')
echo ${LB_IP_ADDRESS}
```

```bash
curl http://${LB_IP_ADDRESS}/ping
```

```json
{
  "host": "<your-ingress-endpoint-ip>",
  "message": "ping-api",
  "method": "GET",
  "url": "http://<your-ingress-endpoint-ip>/ping"
}
```

---

## Screenshots

- Loadbalncer

![loadbalancer](./screenshots/loadbalancer.png?raw=true)

- Loadbalncer Details

![loadbalancer-details](./screenshots/loadbalancer-details.png?raw=true)

---

## Cleanup

```bash
kubectl delete -f app/python-ping-api.yaml

gcloud container clusters delete sample-cluster
```

## References

- [Cloud SDK > Documentation > Reference > gcloud container clusters](https://cloud.google.com/sdk/gcloud/reference/container/clusters)

- [Google Kubernetes Engine (GKE) > Documentation > Guides > GKE Ingress for HTTP(S) Load Balancing](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress)
