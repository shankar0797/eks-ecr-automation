#!/bin/bash

set -euo pipefail

# ============================================================
# Configuration
# ============================================================

AWS_REGION="ap-south-1"
AWS_ACCOUNT_ID="683604924610"

ECR_REPOSITORY="eks-demo-app"
EKS_CLUSTER="eks-lab"

DEPLOYMENT_NAME="eks-demo-app"
CONTAINER_NAME="eks-demo-app"
K8S_NAMESPACE="default"

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

VERSION=$(date +%Y%m%d%H%M%S)

IMAGE_NAME="${ECR_REPOSITORY}:${VERSION}"
ECR_IMAGE="${ECR_REGISTRY}/${ECR_REPOSITORY}:${VERSION}"


# ============================================================
# Functions
# ============================================================

log() {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}


# ============================================================
# 1. Validate required commands
# ============================================================

log "Checking required commands"

command -v aws >/dev/null
command -v docker >/dev/null
command -v kubectl >/dev/null

echo "AWS CLI   : OK"
echo "Docker    : OK"
echo "kubectl   : OK"


# ============================================================
# 2. Verify AWS identity
# ============================================================

log "Checking AWS identity"

aws sts get-caller-identity


# ============================================================
# 3. Authenticate Docker with ECR
# ============================================================

log "Logging in to Amazon ECR"

aws ecr get-login-password \
    --region "$AWS_REGION" |
docker login \
    --username AWS \
    --password-stdin "$ECR_REGISTRY"


# ============================================================
# 4. Build Docker image
# ============================================================

log "Building Docker image"

docker build \
    -t "$IMAGE_NAME" \
    .


# ============================================================
# 5. Tag Docker image
# ============================================================

log "Tagging Docker image"

docker tag \
    "$IMAGE_NAME" \
    "$ECR_IMAGE"


# ============================================================
# 6. Push image to ECR
# ============================================================

log "Pushing image to ECR"

docker push "$ECR_IMAGE"

# ============================================================
# 6.1 Verify image exists in ECR
# ============================================================

log "Verifying image in ECR"

aws ecr describe-images \
    --repository-name "$ECR_REPOSITORY" \
    --image-ids imageTag="$VERSION" \
    --region "$AWS_REGION" \
    >/dev/null

echo "ECR image verified:"
echo "$ECR_IMAGE"

# ============================================================
# 7. Configure kubectl for EKS
# ============================================================

log "Updating EKS kubeconfig"

aws eks update-kubeconfig \
    --region "$AWS_REGION" \
    --name "$EKS_CLUSTER"


# ============================================================
# 8. Apply Kubernetes manifests
# ============================================================

log "Applying Kubernetes manifests"

kubectl apply \
    -f k8s/deployment.yaml

kubectl apply \
    -f k8s/service.yaml


# ============================================================
# 9. Update Deployment image
# ============================================================

log "Updating Deployment image"

kubectl set image \
    deployment/"$DEPLOYMENT_NAME" \
    "$CONTAINER_NAME=$ECR_IMAGE" \
    -n "$K8S_NAMESPACE"


# ============================================================
# 10. Wait for rollout
# ============================================================

log "Waiting for Deployment rollout"

kubectl rollout status \
    deployment/"$DEPLOYMENT_NAME" \
    -n "$K8S_NAMESPACE"


# ============================================================
# 11. Verify deployment
# ============================================================

log "Deployment status"

kubectl get deployment "$DEPLOYMENT_NAME"

echo

kubectl get pods \
    -l app="$DEPLOYMENT_NAME"

echo

kubectl get svc "$DEPLOYMENT_NAME"


# ============================================================
# 12. Deployment completed
# ============================================================

log "Deployment completed successfully"

echo "Image deployed:"
echo "$ECR_IMAGE"
