#!/bin/bash

# Docker Build and Push Script
# Usage: ./docker-build.sh <docker-username>

set -e

if [ -z "$1" ]; then
    echo "Usage: ./docker-build.sh <docker-username>"
    echo "Example: ./docker-build.sh sumitsingh00"
    exit 1
fi

DOCKER_USERNAME=$1
REGISTRY=${DOCKER_USERNAME}
BACKEND_IMAGE="${REGISTRY}/resume-analysis-backend"
FRONTEND_IMAGE="${REGISTRY}/resume-analysis-frontend"
TAG="latest"

echo "========================================"
echo "Building Resume Analysis Chat Bot"
echo "========================================"
echo "Registry: $REGISTRY"
echo "Backend Image: $BACKEND_IMAGE:$TAG"
echo "Frontend Image: $FRONTEND_IMAGE:$TAG"
echo "========================================"

# Build Backend
echo ""
echo "Building Backend Docker image..."
docker build -t ${BACKEND_IMAGE}:${TAG} -t ${BACKEND_IMAGE}:v1 ./Backend
echo "✓ Backend image built successfully"

# Build Frontend
echo ""
echo "Building Frontend Docker image..."
docker build -t ${FRONTEND_IMAGE}:${TAG} -t ${FRONTEND_IMAGE}:v1 ./Frontend
echo "✓ Frontend image built successfully"

# Push images
read -p "Push images to registry? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Pushing Backend image..."
    docker push ${BACKEND_IMAGE}:${TAG}
    docker push ${BACKEND_IMAGE}:v1
    echo "✓ Backend image pushed"
    
    echo ""
    echo "Pushing Frontend image..."
    docker push ${FRONTEND_IMAGE}:${TAG}
    docker push ${FRONTEND_IMAGE}:v1
    echo "✓ Frontend image pushed"
    
    echo ""
    echo "========================================"
    echo "All images built and pushed successfully!"
    echo "========================================"
    echo ""
    echo "Update k8s/backend-deployment.yaml with:"
    echo "  image: ${BACKEND_IMAGE}:${TAG}"
    echo ""
    echo "Update k8s/frontend-deployment.yaml with:"
    echo "  image: ${FRONTEND_IMAGE}:${TAG}"
else
    echo "Skipped pushing images to registry"
fi
