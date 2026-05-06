#!/bin/bash

# Kubernetes Deployment Script
# Usage: ./k8s-deploy.sh

set -e

NAMESPACE="resume-app"

echo "========================================"
echo "Deploying to Kubernetes"
echo "========================================"

# Create namespace and configmap
echo ""
echo "1. Creating namespace and configmap..."
kubectl apply -f k8s/namespace-configmap.yaml
echo "✓ Namespace and configmap created"

# Create secrets
echo ""
echo "2. Creating secrets..."
echo "   NOTE: Edit k8s/secrets.yaml with your actual values before deploying to production!"
kubectl apply -f k8s/secrets.yaml
echo "✓ Secrets created"

# Deploy MongoDB
echo ""
echo "3. Deploying MongoDB..."
kubectl apply -f k8s/mongodb-statefulset.yaml
echo "   Waiting for MongoDB to be ready..."
kubectl wait --for=condition=Ready pod -l app=mongodb -n ${NAMESPACE} --timeout=300s
echo "✓ MongoDB deployed and ready"

# Deploy Backend
echo ""
echo "4. Deploying Backend..."
kubectl apply -f k8s/backend-deployment.yaml
echo "   Waiting for Backend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/backend -n ${NAMESPACE}
echo "✓ Backend deployed"

# Deploy Frontend
echo ""
echo "5. Deploying Frontend..."
kubectl apply -f k8s/frontend-deployment.yaml
echo "   Waiting for Frontend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n ${NAMESPACE}
echo "✓ Frontend deployed"

# Deploy HPA
echo ""
echo "6. Setting up Autoscaling..."
kubectl apply -f k8s/hpa.yaml
echo "✓ Autoscaling configured"

# Deploy Ingress
echo ""
echo "7. Deploying Ingress..."
kubectl apply -f k8s/ingress.yaml
echo "✓ Ingress deployed"

echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo ""
echo "Verification:"
kubectl get pods -n ${NAMESPACE}
echo ""
echo "Access the application:"
echo "  kubectl port-forward svc/frontend-service 3000:80 -n ${NAMESPACE}"
echo ""
echo "View logs:"
echo "  kubectl logs -f deployment/backend -n ${NAMESPACE}"
echo "  kubectl logs -f deployment/frontend -n ${NAMESPACE}"
