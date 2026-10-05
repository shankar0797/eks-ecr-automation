# EKS ECR Automation

This project demonstrates an end-to-end Kubernetes deployment workflow using a jump server to build a Docker application, push the image to Amazon ECR, deploy it to Amazon EKS, and monitor the application using Prometheus and Grafana.

The deployment process is automated using a Bash script.

---

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
             |
             v
        Amazon ECR
             |
             v
        Amazon EKS
             |
             v
    Kubernetes Service
             |
             v
      Flask Application
         |        |
         |        +----> /health
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
```

## Technologies Used

- AWS EC2
- Amazon ECR
- Amazon EKS
- Kubernetes
- Docker
- Python
- Flask
- Bash
- Helm
- Prometheus
- Grafana
- ServiceMonitor

---

## Project Structure

```text
eks-ecr-automation/
|
├── app.py
├── requirements.txt
├── Dockerfile
|
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── servicemonitor.yaml
|
├── scripts/
│   └── deploy.sh
|
├── .dockerignore
├── .gitignore
└── README.md
```

---

## Application Endpoints

| Endpoint | Purpose |
|---|---|
| `/` | Application information |
| `/health` | Application health check |
| `/metrics` | Prometheus metrics |

---

## Deployment Flow

The complete deployment flow is automated using `scripts/deploy.sh`.

```text
1. Check required tools
        |
        v
2. Verify AWS identity
        |
        v
3. Login to Amazon ECR
        |
        v
4. Build Docker image
        |
        v
5. Tag Docker image
        |
        v
6. Push image to ECR
        |
        v
7. Verify image in ECR
        |
        v
8. Update EKS kubeconfig
        |
        v
9. Apply Kubernetes manifests
        |
        v
10. Update Deployment image
        |
        v
11. Wait for rollout
        |
        v
12. Verify deployment
```

---

## Docker Build

Build the application image:

```bash
docker build -t eks-demo-app:1.0 .
```

Run the application locally:

```bash
docker run -d \
  --name eks-demo-app \
  -p 8000:8000 \
  eks-demo-app:1.0
```

Test the application:

```bash
curl http://localhost:8000
curl http://localhost:8000/health
curl http://localhost:8000/metrics
```

---

## Amazon ECR

Login to Amazon ECR:

```bash
aws ecr get-login-password --region ap-south-1 | \
docker login \
  --username AWS \
  --password-stdin \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com
```

Tag the Docker image:

```bash
docker tag \
  eks-demo-app:1.0 \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/eks-demo-app:1.0
```

Push the image:

```bash
docker push \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/eks-demo-app:1.0
```

The deployment script performs these steps automatically.

---

## Amazon EKS Deployment

Update the local kubeconfig:

```bash
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name eks-lab
```

Apply the Kubernetes resources:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/servicemonitor.yaml
```

Check the resources:

```bash
kubectl get deployment
kubectl get pods
kubectl get svc
```

Check rollout status:

```bash
kubectl rollout status deployment/eks-demo-app
```

---

## Automated Deployment

The complete build, push, and deployment workflow can be executed with:

```bash
./scripts/deploy.sh
```

The script performs:

1. AWS CLI, Docker, and kubectl validation
2. AWS identity verification
3. Amazon ECR authentication
4. Docker image build
5. Docker image tagging
6. Image push to ECR
7. ECR image verification
8. EKS kubeconfig update
9. Kubernetes manifest application
10. Deployment image update
11. Deployment rollout verification
12. Final deployment status check

---

## Monitoring

The Flask application exposes Prometheus metrics through `/metrics`.

```text
Flask Application
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
```

The Grafana dashboard contains:

- Request rate
- Total requests
- HTTP status codes
- Request latency

---

## Prometheus Queries

### Request Rate

```promql
sum(rate(http_requests_total[1m]))
```

### Total Requests

```promql
sum(http_requests_total)
```

### HTTP Status Codes

```promql
sum by (status) (http_requests_total)
```

### Request Latency

```promql
sum(rate(http_request_duration_seconds_sum[1m]))
/
sum(rate(http_request_duration_seconds_count[1m]))
```

---

## Troubleshooting Scenarios

### 1. Docker Port Conflict

**Problem:** Port `8000` was already being used.

**Cause:** Another Flask process or Docker container was already listening on port `8000`.

**Resolution:** Identify and stop the process/container using the port, then start the new container.

---

### 2. ImagePullBackOff

**Problem:** Kubernetes failed to pull the application image.

**Root Cause:** The deployment referenced a timestamp-based image tag that did not exist in ECR.

```text
ECR Image      -> :1.0
EKS Deployment -> :20261005214530
```

**Resolution:** Ensure the image is pushed to ECR and verified before updating the Kubernetes Deployment.

---

### 3. Service Has No Endpoints

**Problem:** The Kubernetes Service could not reach the application Pod.

**Root Cause:** The Service selector did not match the labels on the Pod.

Service:

```yaml
selector:
  app: eks-demo-app
```

Pod:

```yaml
labels:
  app: eks-demo-app
```

The selector and labels must match.

---

### 4. Prometheus Metrics Not Available

**Problem:** The `/metrics` endpoint returned an error.

**Cause:** The running Pod was using an older application image that did not contain the Prometheus client implementation.

**Resolution:** Build and deploy the updated application image and verify:

```bash
curl http://<SERVICE>/metrics
```

---

### 5. Grafana Plugin Error

**Problem:** Grafana displayed:

```text
Plugin not registered
```

**Root Cause:** The Prometheus plugin update failed because the plugin filesystem was read-only.

**Resolution:** Restart the Grafana Deployment and verify the Prometheus datasource again.

```bash
kubectl rollout restart deployment/kube-prometheus-stack-grafana -n monitoring
kubectl rollout status deployment/kube-prometheus-stack-grafana -n monitoring
```

---

## Key Learnings

- Docker image build and tagging
- Amazon ECR authentication and image management
- Kubernetes Deployments
- Kubernetes Services
- EKS networking
- Readiness probes
- ECR-to-EKS image deployment
- Bash deployment automation
- Prometheus application metrics
- ServiceMonitor
- Grafana dashboards
- Kubernetes troubleshooting
- End-to-end deployment automation

---

## Future Improvements

- Jenkins CI/CD pipeline
- GitHub Actions
- Helm-based application deployment
- Container security scanning
- Image vulnerability scanning
- Prometheus alerting
- Centralized logging
- Distributed tracing
- CloudWatch integration
- P95/P99 latency monitoring
- Dynamic application version injection
- Secrets management
# EKS ECR Automation

This project demonstrates an end-to-end Kubernetes deployment workflow using a jump server to build a Docker application, push the image to Amazon ECR, deploy it to Amazon EKS, and monitor the application using Prometheus and Grafana.

The deployment process is automated using a Bash script.

---

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
             |
             v
        Amazon ECR
             |
             v
        Amazon EKS
             |
             v
    Kubernetes Service
             |
             v
      Flask Application
         |        |
         |        +----> /health
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
```

## Technologies Used

- AWS EC2
- Amazon ECR
- Amazon EKS
- Kubernetes
- Docker
- Python
- Flask
- Bash
- Helm
- Prometheus
- Grafana
- ServiceMonitor

---

## Project Structure

```text
eks-ecr-automation/
|
├── app.py
├── requirements.txt
├── Dockerfile
|
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── servicemonitor.yaml
|
├── scripts/
│   └── deploy.sh
|
├── .dockerignore
├── .gitignore
└── README.md
```

---

## Application Endpoints

| Endpoint | Purpose |
|---|---|
| `/` | Application information |
| `/health` | Application health check |
| `/metrics` | Prometheus metrics |

---

## Deployment Flow

The complete deployment flow is automated using `scripts/deploy.sh`.

```text
1. Check required tools
        |
        v
2. Verify AWS identity
        |
        v
3. Login to Amazon ECR
        |
        v
4. Build Docker image
        |
        v
5. Tag Docker image
        |
        v
6. Push image to ECR
        |
        v
7. Verify image in ECR
        |
        v
8. Update EKS kubeconfig
        |
        v
9. Apply Kubernetes manifests
        |
        v
10. Update Deployment image
        |
        v
11. Wait for rollout
        |
        v
12. Verify deployment
```

---

## Docker Build

Build the application image:

```bash
docker build -t eks-demo-app:1.0 .
```

Run the application locally:

```bash
docker run -d \
  --name eks-demo-app \
  -p 8000:8000 \
  eks-demo-app:1.0
```

Test the application:

```bash
curl http://localhost:8000
curl http://localhost:8000/health
curl http://localhost:8000/metrics
```

---

## Amazon ECR

Login to Amazon ECR:

```bash
aws ecr get-login-password --region ap-south-1 | \
docker login \
  --username AWS \
  --password-stdin \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com
```

Tag the Docker image:

```bash
docker tag \
  eks-demo-app:1.0 \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/eks-demo-app:1.0
```

Push the image:

```bash
docker push \
  <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/eks-demo-app:1.0
```

The deployment script performs these steps automatically.

---

## Amazon EKS Deployment

Update the local kubeconfig:

```bash
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name eks-lab
```

Apply the Kubernetes resources:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/servicemonitor.yaml
```

Check the resources:

```bash
kubectl get deployment
kubectl get pods
kubectl get svc
```

Check rollout status:

```bash
kubectl rollout status deployment/eks-demo-app
```

---

## Automated Deployment

The complete build, push, and deployment workflow can be executed with:

```bash
./scripts/deploy.sh
```

The script performs:

1. AWS CLI, Docker, and kubectl validation
2. AWS identity verification
3. Amazon ECR authentication
4. Docker image build
5. Docker image tagging
6. Image push to ECR
7. ECR image verification
8. EKS kubeconfig update
9. Kubernetes manifest application
10. Deployment image update
11. Deployment rollout verification
12. Final deployment status check

---

## Monitoring

The Flask application exposes Prometheus metrics through `/metrics`.

```text
Flask Application
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
```

The Grafana dashboard contains:

- Request rate
- Total requests
- HTTP status codes
- Request latency

---

## Prometheus Queries

### Request Rate

```promql
sum(rate(http_requests_total[1m]))
```

### Total Requests

```promql
sum(http_requests_total)
```

### HTTP Status Codes

```promql
sum by (status) (http_requests_total)
```

### Request Latency

```promql
sum(rate(http_request_duration_seconds_sum[1m]))
/
sum(rate(http_request_duration_seconds_count[1m]))
```

---

## Troubleshooting Scenarios

### 1. Docker Port Conflict

**Problem:** Port `8000` was already being used.

**Cause:** Another Flask process or Docker container was already listening on port `8000`.

**Resolution:** Identify and stop the process/container using the port, then start the new container.

---

### 2. ImagePullBackOff

**Problem:** Kubernetes failed to pull the application image.

**Root Cause:** The deployment referenced a timestamp-based image tag that did not exist in ECR.

```text
ECR Image      -> :1.0
EKS Deployment -> :20261005214530
```

**Resolution:** Ensure the image is pushed to ECR and verified before updating the Kubernetes Deployment.

---

### 3. Service Has No Endpoints

**Problem:** The Kubernetes Service could not reach the application Pod.

**Root Cause:** The Service selector did not match the labels on the Pod.

Service:

```yaml
selector:
  app: eks-demo-app
```

Pod:

```yaml
labels:
  app: eks-demo-app
```

The selector and labels must match.

---

### 4. Prometheus Metrics Not Available

**Problem:** The `/metrics` endpoint returned an error.

**Cause:** The running Pod was using an older application image that did not contain the Prometheus client implementation.

**Resolution:** Build and deploy the updated application image and verify:

```bash
curl http://<SERVICE>/metrics
```

---

### 5. Grafana Plugin Error

**Problem:** Grafana displayed:

```text
Plugin not registered
```

**Root Cause:** The Prometheus plugin update failed because the plugin filesystem was read-only.

**Resolution:** Restart the Grafana Deployment and verify the Prometheus datasource again.

```bash
kubectl rollout restart deployment/kube-prometheus-stack-grafana -n monitoring
kubectl rollout status deployment/kube-prometheus-stack-grafana -n monitoring
```

---

## Key Learnings

- Docker image build and tagging
- Amazon ECR authentication and image management
- Kubernetes Deployments
- Kubernetes Services
- EKS networking
- Readiness probes
- ECR-to-EKS image deployment
- Bash deployment automation
- Prometheus application metrics
- ServiceMonitor
- Grafana dashboards
- Kubernetes troubleshooting
- End-to-end deployment automation

---

## Future Improvements

- Jenkins CI/CD pipeline
- GitHub Actions
- Helm-based application deployment
- Container security scanning
- Image vulnerability scanning
- Prometheus alerting
- Centralized logging
- Distributed tracing
- CloudWatch integration
- P95/P99 latency monitoring
- Dynamic application version injection
- Secrets management
