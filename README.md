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
Project Structure
eks-ecr-automation/
│
├── app.py
├── requirements.txt
├── Dockerfile
│
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── servicemonitor.yaml
│
├── scripts/
│   └── deploy.sh
│
├── .dockerignore
├── .gitignore
└── README.md
Application Endpoints
Endpoint	Purpose
/	Application information
/health	Health check
/metrics	Prometheus metrics
Deployment Flow

The deployment is automated using scripts/deploy.sh.

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
Monitoring

Prometheus collects application metrics exposed through /metrics.

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

The Grafana dashboard provides:

Request rate
Total requests
HTTP status codes
Request latency
Docker Build
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

Login to ECR:

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

Update kubeconfig:

aws eks update-kubeconfig \
  --region ap-south-1 \
  --name eks-lab

Apply Kubernetes resources:

kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/servicemonitor.yaml

Check the deployment:

kubectl get deployment
kubectl get pods
kubectl get svc

Check rollout:

kubectl rollout status deployment/eks-demo-app
Automated Deployment

The complete deployment can be executed using:

./scripts/deploy.sh

The script performs:

AWS identity verification
ECR authentication
Docker image build
Image tagging
ECR push
ECR image verification
EKS kubeconfig update
Kubernetes manifest deployment
Deployment image update
Rollout verification
Troubleshooting Scenarios
Docker Port Conflict

Problem: Port 8000 was already being used.

Resolution:

Identify the process/container using the port and stop it before starting the new container.

ImagePullBackOff

Problem: Kubernetes attempted to pull a timestamp-based image tag that did not exist in ECR.

Root Cause:

ECR Image      → :1.0
EKS Deployment → :20261005214530

Resolution:

Push the required image tag to ECR and verify the image before updating the Kubernetes Deployment.

Service Has No Endpoints

Problem: Service could not reach the application Pods.

Root Cause:

The Service selector did not match the Pod labels.

Resolution:

Ensure:

selector:
  app: eks-demo-app

matches:

labels:
  app: eks-demo-app
Grafana Plugin Error

Problem: Grafana showed:

Plugin not registered

Root Cause:

The Prometheus plugin update failed because the plugin filesystem was read-only.

Resolution:

Restart the Grafana Deployment and verify the datasource again.

Key Learnings
Docker image build and tagging
Amazon ECR authentication and image management
Kubernetes Deployments
Kubernetes Services
EKS networking
Kubernetes readiness probes
ECR → EKS image deployment
Bash deployment automation
Prometheus metrics
ServiceMonitor
Grafana dashboards
Kubernetes troubleshooting
Production-style deployment workflow
Future Improvements
Jenkins CI/CD pipeline
GitHub Actions
Helm-based deployment
Container security scanning
Image vulnerability scanning
Prometheus alerting
Centralized logging
Distributed tracing
CloudWatch integration
P95/P99 latency monitoring
Dynamic application version injection
Secrets management# EKS ECR Automation

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
Project Structure
eks-ecr-automation/
│
├── app.py
├── requirements.txt
├── Dockerfile
│
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── servicemonitor.yaml
│
├── scripts/
│   └── deploy.sh
│
├── .dockerignore
├── .gitignore
└── README.md
Application Endpoints
Endpoint	Purpose
/	Application information
/health	Health check
/metrics	Prometheus metrics
Deployment Flow

The deployment is automated using scripts/deploy.sh.

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
Monitoring

Prometheus collects application metrics exposed through /metrics.

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

The Grafana dashboard provides:

Request rate
Total requests
HTTP status codes
Request latency
Docker Build
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

Login to ECR:

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

Update kubeconfig:

aws eks update-kubeconfig \
  --region ap-south-1 \
  --name eks-lab

Apply Kubernetes resources:

kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/servicemonitor.yaml

Check the deployment:

kubectl get deployment
kubectl get pods
kubectl get svc

Check rollout:

kubectl rollout status deployment/eks-demo-app
Automated Deployment

The complete deployment can be executed using:

./scripts/deploy.sh

The script performs:

AWS identity verification
ECR authentication
Docker image build
Image tagging
ECR push
ECR image verification
EKS kubeconfig update
Kubernetes manifest deployment
Deployment image update
Rollout verification
Troubleshooting Scenarios
Docker Port Conflict

Problem: Port 8000 was already being used.

Resolution:

Identify the process/container using the port and stop it before starting the new container.

ImagePullBackOff

Problem: Kubernetes attempted to pull a timestamp-based image tag that did not exist in ECR.

Root Cause:

ECR Image      → :1.0
EKS Deployment → :20261005214530

Resolution:

Push the required image tag to ECR and verify the image before updating the Kubernetes Deployment.

Service Has No Endpoints

Problem: Service could not reach the application Pods.

Root Cause:

The Service selector did not match the Pod labels.

Resolution:

Ensure:

selector:
  app: eks-demo-app

matches:

labels:
  app: eks-demo-app
Grafana Plugin Error

Problem: Grafana showed:

Plugin not registered

Root Cause:

The Prometheus plugin update failed because the plugin filesystem was read-only.

Resolution:

Restart the Grafana Deployment and verify the datasource again.

Key Learnings
Docker image build and tagging
Amazon ECR authentication and image management
Kubernetes Deployments
Kubernetes Services
EKS networking
Kubernetes readiness probes
ECR → EKS image deployment
Bash deployment automation
Prometheus metrics
ServiceMonitor
Grafana dashboards
Kubernetes troubleshooting
Production-style deployment workflow
Future Improvements
Jenkins CI/CD pipeline
GitHub Actions
Helm-based deployment
Container security scanning
Image vulnerability scanning
Prometheus alerting
Centralized logging
Distributed tracing
CloudWatch integration
P95/P99 latency monitoring
Dynamic application version injection
Secrets management
