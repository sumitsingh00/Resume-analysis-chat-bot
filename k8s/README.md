# Kubernetes Deployment Guide

## Prerequisites
- kubectl installed and configured
- A Kubernetes cluster (EKS, GKE, AKS, or local Minikube)
- Docker images pushed to a container registry (Docker Hub, ECR, etc.)

## Building and Pushing Docker Images

### Build Backend Image
```bash
docker build -t sumitsingh00/resume-analysis-backend:latest ./Backend
docker push sumitsingh00/resume-analysis-backend:latest
```

### Build Frontend Image
```bash
docker build -t sumitsingh00/resume-analysis-frontend:latest ./Frontend
docker push sumitsingh00/resume-analysis-frontend:latest
```

## Deployment Steps

### 1. Create Namespace and ConfigMap
```bash
kubectl apply -f k8s/namespace-configmap.yaml
```

### 2. Create Secrets (Update values first!)
Edit `k8s/secrets.yaml` with your actual secret values:
```bash
kubectl apply -f k8s/secrets.yaml
```

### 3. Deploy MongoDB
```bash
kubectl apply -f k8s/mongodb-statefulset.yaml
```

Wait for MongoDB to be ready:
```bash
kubectl wait --for=condition=Ready pod -l app=mongodb -n resume-app --timeout=300s
```

### 4. Deploy Backend
```bash
kubectl apply -f k8s/backend-deployment.yaml
```

### 5. Deploy Frontend
```bash
kubectl apply -f k8s/frontend-deployment.yaml
```

### 6. Apply Autoscaling
```bash
kubectl apply -f k8s/hpa.yaml
```

### 7. Setup Ingress (Optional, for domain routing)
```bash
kubectl apply -f k8s/ingress.yaml
```

## Verify Deployment

```bash
# Check pods
kubectl get pods -n resume-app

# Check services
kubectl get svc -n resume-app

# Check deployments
kubectl get deployments -n resume-app

# View logs
kubectl logs -f deployment/backend -n resume-app
kubectl logs -f deployment/frontend -n resume-app

# Describe pod for debugging
kubectl describe pod <pod-name> -n resume-app
```

## Useful kubectl Commands

```bash
# Port forward to access services locally
kubectl port-forward svc/frontend-service 3000:80 -n resume-app
kubectl port-forward svc/backend-service 5000:5000 -n resume-app

# Check resource usage
kubectl top nodes -n resume-app
kubectl top pods -n resume-app

# Restart deployment
kubectl rollout restart deployment/backend -n resume-app

# View resource limits
kubectl describe node

# Get detailed pod info
kubectl get pods -n resume-app -o wide
```

## Scaling

### Manual Scaling
```bash
kubectl scale deployment backend --replicas=3 -n resume-app
```

### Auto-scaling is configured in hpa.yaml
Pods will automatically scale based on CPU (70%) and Memory (80%) utilization.

## Cleanup

```bash
# Delete all resources
kubectl delete namespace resume-app

# Or delete specific resources
kubectl delete -f k8s/
```

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name> -n resume-app
kubectl logs <pod-name> -n resume-app
```

### Connection issues
```bash
# Test connectivity between pods
kubectl exec -it <pod-name> -n resume-app -- /bin/sh
# Inside pod: curl http://backend-service:5000/health
```

### Persistent volume issues
```bash
kubectl get pvc -n resume-app
kubectl describe pvc mongodb-pvc -n resume-app
```
