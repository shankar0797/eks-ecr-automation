# EKS ECR Automation with Prometheus & Grafana

## Project Overview

This project demonstrates an end-to-end Kubernetes deployment workflow using a jump server to build a Docker application, push the image to Amazon ECR, deploy it to Amazon EKS, and monitor the application using Prometheus and Grafana.

The deployment process is automated using a Bash script.

## Architecture

```text
Developer
    |
    v
Jump Server / EC2
    |
    | deploy.sh
    |
    +----> Docker Build
    |          |
    |          v
    |       Amazon ECR
    |          |
    |          v
    +----> Amazon EKS
               |
               v
        Kubernetes Service
               |
               v
        Flask Application
          |           |
          |           +----> /health
          |
          +----> /metrics
                    |
                    v
              ServiceMonitor
                    |
                    v
                Prometheus
                    |
                    v
                 Grafana
Technologies Used
AWS EC2
Amazon ECR
Amazon EKS
Kubernetes
Docker
Python
Flask
Bash
Helm
Prometheus
Grafana
ServiceMonitor
kubectl
AWS CLI
Project Structure
eks-ecr-automation/
│
├── .dockerignore
├── .gitignore
├── Dockerfile
├── app.py
├── requirements.txt
│
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── servicemonitor.yaml
│
└── scripts/
    └── deploy.sh
Application

The application is a simple Flask API.

Endpoints
GET /
GET /health
GET /metrics

Example:

{
  "message": "EKS ECR Automation Demo",
  "version": "docker"
}

The /metrics endpoint exposes Prometheus metrics.

Application metrics include:

http_requests_total
http_request_duration_seconds
Docker

Build the application image:

docker build -t eks-demo-app:1.0 .

Run locally:

docker run -d \
  --name eks-demo-app \
  -p 8000:8000 \
  eks-demo-app:1.0

Test:

curl http://localhost:8000
curl http://localhost:8000/health
curl http://localhost:8000/metrics
Amazon ECR

Authenticate Docker with ECR:

aws ecr get-login-password --region ap-south-1 | \
docker login \
  --username AWS \
  --password-stdin \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com

Tag the image:

docker tag \
  eks-demo-app:1.0 \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/eks-demo-app:1.0

Push:

docker push \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/eks-demo-app:1.0
Amazon EKS Deployment

The Kubernetes deployment uses the image stored in ECR.

Apply the manifests:

kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

Verify:

kubectl get deployment
kubectl get pods
kubectl get svc

Check the application:

kubectl get pods -l app=eks-demo-app
Deployment Automation

The complete build and deployment process is automated using:

scripts/deploy.sh

The script performs:

Validate required tools
Check AWS identity
Authenticate with ECR
Build Docker image
Tag image
Push image to ECR
Verify image exists in ECR
Update EKS kubeconfig
Apply Kubernetes manifests
Update Deployment image
Wait for rollout
Display deployment status

Run:

./scripts/deploy.sh

The script generates a timestamp-based image version, for example:

eks-demo-app:20261005162458
Monitoring

Prometheus and Grafana were deployed using:

kube-prometheus-stack

The application exposes:

/metrics

A Kubernetes ServiceMonitor discovers the application Service and instructs Prometheus to scrape the metrics endpoint.

Monitoring flow:

Flask
  |
  | /metrics
  v
Kubernetes Service
  |
  v
ServiceMonitor
  |
  v
Prometheus
  |
  v
Grafana
Grafana Dashboard

The Grafana dashboard contains application-level metrics including:

Request Rate
sum(rate(http_requests_total[1m]))

Shows the application request rate.

Total Requests
sum(http_requests_total)

Shows the cumulative number of HTTP requests.

HTTP Status Codes
sum by (status) (http_requests_total)

Shows requests grouped by HTTP status code.

Request Latency
sum(rate(http_request_duration_seconds_sum[1m]))
/
sum(rate(http_request_duration_seconds_count[1m]))

Shows average request latency.

Troubleshooting Scenarios
Docker Port Conflict

Problem:

Bind for 0.0.0.0:8000 failed

Cause:

Another process/container was already using port 8000.

Resolution:

docker ps
docker stop <container>

or stop the local Flask process.

EKS ImagePullBackOff

Problem:

New EKS pod entered:

ImagePullBackOff

Root cause:

The Deployment referenced a timestamp image tag that had not been pushed to ECR.

Example:

ECR:
eks-demo-app:1.0

EKS:
eks-demo-app:20261005162458

Resolution:

Ensure the exact image tag is successfully pushed to ECR before updating the Deployment.

Kubernetes Service Has No Endpoints

Problem:

Service was not routing traffic to Pods.

Root cause:

Service selector did not match the Pod labels.

Verify:

kubectl get endpointslice
kubectl describe service eks-demo-app
kubectl get pods --show-labels

Resolution:

Ensure:

selector:
  app: eks-demo-app

matches the Pod label.

Prometheus Metrics Not Found

Problem:

/metrics returned 404.

Root cause:

EKS was still running the older application image without Prometheus instrumentation.

Resolution:

Build, push and deploy the observability-enabled image.

Grafana Prometheus Plugin Error

Problem:

Grafana reported:

plugin not registered

Root cause:

The Prometheus plugin update attempted to modify a read-only bundled plugin filesystem.

Resolution:

Restart Grafana and verify the plugin registration.

kubectl rollout restart deployment/kube-prometheus-stack-grafana \
  -n monitoring
Key Learnings
Docker image lifecycle
Amazon ECR image management
Kubernetes Deployments
Kubernetes Services
EKS networking
ECR to EKS image flow
Bash deployment automation
Kubernetes rollout management
Prometheus application instrumentation
ServiceMonitor discovery
Prometheus queries
Grafana dashboards
Kubernetes troubleshooting
Real-world deployment failure handling
Future Improvements

Possible future enhancements:

Jenkins CI/CD pipeline
GitHub Actions
Helm-based application deployment
Container image security scanning
Prometheus alerting
Alertmanager
Centralized logging
Distributed tracing
AWS CloudWatch integration
P95/P99 latency dashboards
Deployment version injection
Secrets management# EKS ECR Automation with Prometheus & Grafana

## Project Overview

This project demonstrates an end-to-end Kubernetes deployment workflow using a jump server to build a Docker application, push the image to Amazon ECR, deploy it to Amazon EKS, and monitor the application using Prometheus and Grafana.

The deployment process is automated using a Bash script.

## Architecture

```text
Developer
    |
    v
Jump Server / EC2
    |
    | deploy.sh
    |
    +----> Docker Build
    |          |
    |          v
    |       Amazon ECR
    |          |
    |          v
    +----> Amazon EKS
               |
               v
        Kubernetes Service
               |
               v
        Flask Application
          |           |
          |           +----> /health
          |
          +----> /metrics
                    |
                    v
              ServiceMonitor
                    |
                    v
                Prometheus
                    |
                    v
                 Grafana
Technologies Used
AWS EC2
Amazon ECR
Amazon EKS
Kubernetes
Docker
Python
Flask
Bash
Helm
Prometheus
Grafana
ServiceMonitor
kubectl
AWS CLI
Project Structure
eks-ecr-automation/
│
├── .dockerignore
├── .gitignore
├── Dockerfile
├── app.py
├── requirements.txt
│
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── servicemonitor.yaml
│
└── scripts/
    └── deploy.sh
Application

The application is a simple Flask API.

Endpoints
GET /
GET /health
GET /metrics

Example:

{
  "message": "EKS ECR Automation Demo",
  "version": "docker"
}

The /metrics endpoint exposes Prometheus metrics.

Application metrics include:

http_requests_total
http_request_duration_seconds
Docker

Build the application image:

docker build -t eks-demo-app:1.0 .

Run locally:

docker run -d \
  --name eks-demo-app \
  -p 8000:8000 \
  eks-demo-app:1.0

Test:

curl http://localhost:8000
curl http://localhost:8000/health
curl http://localhost:8000/metrics
Amazon ECR

Authenticate Docker with ECR:

aws ecr get-login-password --region ap-south-1 | \
docker login \
  --username AWS \
  --password-stdin \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com

Tag the image:

docker tag \
  eks-demo-app:1.0 \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/eks-demo-app:1.0

Push:

docker push \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/eks-demo-app:1.0
Amazon EKS Deployment

The Kubernetes deployment uses the image stored in ECR.

Apply the manifests:

kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

Verify:

kubectl get deployment
kubectl get pods
kubectl get svc

Check the application:

kubectl get pods -l app=eks-demo-app
Deployment Automation

The complete build and deployment process is automated using:

scripts/deploy.sh

The script performs:

Validate required tools
Check AWS identity
Authenticate with ECR
Build Docker image
Tag image
Push image to ECR
Verify image exists in ECR
Update EKS kubeconfig
Apply Kubernetes manifests
Update Deployment image
Wait for rollout
Display deployment status

Run:

./scripts/deploy.sh

The script generates a timestamp-based image version, for example:

eks-demo-app:20261005162458
Monitoring

Prometheus and Grafana were deployed using:

kube-prometheus-stack

The application exposes:

/metrics

A Kubernetes ServiceMonitor discovers the application Service and instructs Prometheus to scrape the metrics endpoint.

Monitoring flow:

Flask
  |
  | /metrics
  v
Kubernetes Service
  |
  v
ServiceMonitor
  |
  v
Prometheus
  |
  v
Grafana
Grafana Dashboard

The Grafana dashboard contains application-level metrics including:

Request Rate
sum(rate(http_requests_total[1m]))

Shows the application request rate.

Total Requests
sum(http_requests_total)

Shows the cumulative number of HTTP requests.

HTTP Status Codes
sum by (status) (http_requests_total)

Shows requests grouped by HTTP status code.

Request Latency
sum(rate(http_request_duration_seconds_sum[1m]))
/
sum(rate(http_request_duration_seconds_count[1m]))

Shows average request latency.

Troubleshooting Scenarios
Docker Port Conflict

Problem:

Bind for 0.0.0.0:8000 failed

Cause:

Another process/container was already using port 8000.

Resolution:

docker ps
docker stop <container>

or stop the local Flask process.

EKS ImagePullBackOff

Problem:

New EKS pod entered:

ImagePullBackOff

Root cause:

The Deployment referenced a timestamp image tag that had not been pushed to ECR.

Example:

ECR:
eks-demo-app:1.0

EKS:
eks-demo-app:20261005162458

Resolution:

Ensure the exact image tag is successfully pushed to ECR before updating the Deployment.

Kubernetes Service Has No Endpoints

Problem:

Service was not routing traffic to Pods.

Root cause:

Service selector did not match the Pod labels.

Verify:

kubectl get endpointslice
kubectl describe service eks-demo-app
kubectl get pods --show-labels

Resolution:

Ensure:

selector:
  app: eks-demo-app

matches the Pod label.

Prometheus Metrics Not Found

Problem:

/metrics returned 404.

Root cause:

EKS was still running the older application image without Prometheus instrumentation.

Resolution:

Build, push and deploy the observability-enabled image.

Grafana Prometheus Plugin Error

Problem:

Grafana reported:

plugin not registered

Root cause:

The Prometheus plugin update attempted to modify a read-only bundled plugin filesystem.

Resolution:

Restart Grafana and verify the plugin registration.

kubectl rollout restart deployment/kube-prometheus-stack-grafana \
  -n monitoring
Key Learnings
Docker image lifecycle
Amazon ECR image management
Kubernetes Deployments
Kubernetes Services
EKS networking
ECR to EKS image flow
Bash deployment automation
Kubernetes rollout management
Prometheus application instrumentation
ServiceMonitor discovery
Prometheus queries
Grafana dashboards
Kubernetes troubleshooting
Real-world deployment failure handling
Future Improvements

Possible future enhancements:

Jenkins CI/CD pipeline
GitHub Actions
Helm-based application deployment
Container image security scanning
Prometheus alerting
Alertmanager
Centralized logging
Distributed tracing
AWS CloudWatch integration
P95/P99 latency dashboards
Deployment version injection
Secrets management
