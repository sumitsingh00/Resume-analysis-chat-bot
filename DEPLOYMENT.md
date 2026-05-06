# Production Deployment Guide

## Overview
This guide provides step-by-step instructions for deploying the Resume Analysis Chat Bot to production using Docker and Kubernetes.

## Pre-deployment Checklist

- [ ] All environment variables configured
- [ ] Secrets properly set in Kubernetes
- [ ] Database backups configured
- [ ] SSL/TLS certificates ready
- [ ] Docker images built and pushed to registry
- [ ] Kubernetes cluster provisioned and configured
- [ ] Monitoring and logging setup

## 1. Prepare Docker Images

### Build Images
```bash
chmod +x docker-build.sh
./docker-build.sh sumitsingh00
```

### Push to Registry
Images will be automatically pushed to your Docker Hub account.

## 2. Kubernetes Deployment

### Environment-Specific Configuration

Create environment-specific secret files:

**production-secrets.yaml**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: resume-app
type: Opaque
stringData:
  MONGODB_URI: mongodb+srv://username:password@cluster.mongodb.net/resume_db
  JWT_SECRET: your-production-jwt-secret-key
  GOOGLE_API_KEY: your-production-google-api-key
  CORS_ORIGIN: https://resume-analysis-chat-bot.vercel.app
```

### Deploy to Cluster

```bash
chmod +x k8s-deploy.sh
./k8s-deploy.sh
```

### Manual Steps

If you prefer manual deployment:

```bash
# 1. Create namespace
kubectl create namespace resume-app

# 2. Apply secrets
kubectl apply -f k8s/secrets.yaml

# 3. Apply ConfigMaps
kubectl apply -f k8s/namespace-configmap.yaml

# 4. Deploy MongoDB
kubectl apply -f k8s/mongodb-statefulset.yaml

# 5. Deploy Backend
kubectl apply -f k8s/backend-deployment.yaml

# 6. Deploy Frontend
kubectl apply -f k8s/frontend-deployment.yaml

# 7. Enable Autoscaling
kubectl apply -f k8s/hpa.yaml

# 8. Setup Ingress
kubectl apply -f k8s/ingress.yaml
```

## 3. Database Setup

### MongoDB Atlas (Cloud)
1. Create a cluster at https://www.mongodb.com/cloud/atlas
2. Create a database user
3. Whitelist IP addresses
4. Update `MONGODB_URI` in secrets

### Self-Hosted MongoDB
```bash
# Use the StatefulSet in k8s/mongodb-statefulset.yaml
# Configure persistent storage accordingly
```

## 4. SSL/TLS Setup

### Using Let's Encrypt with cert-manager

```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Create ClusterIssuer
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

### Update Ingress
Update `k8s/ingress.yaml` with your domain and cert-manager annotation.

## 5. Monitoring & Logging

### Kubernetes Dashboard
```bash
kubectl proxy
# Visit http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

### View Pod Logs
```bash
# Backend logs
kubectl logs -f deployment/backend -n resume-app

# Frontend logs
kubectl logs -f deployment/frontend -n resume-app

# MongoDB logs
kubectl logs -f statefulset/mongodb -n resume-app
```

### Resource Monitoring
```bash
# View resource usage
kubectl top nodes
kubectl top pods -n resume-app

# Check HPA status
kubectl get hpa -n resume-app
```

## 6. Scaling Configuration

### Horizontal Pod Autoscaler Settings
Configured in `k8s/hpa.yaml`:
- Min replicas: 2
- Max replicas: 5
- CPU threshold: 70%
- Memory threshold: 80%

Adjust these values based on your traffic patterns.

## 7. Backup Strategy

### MongoDB Backups
```bash
# Backup MongoDB data
kubectl exec -it mongodb-0 -n resume-app -- mongodump --out /tmp/backup

# Restore from backup
kubectl exec -it mongodb-0 -n resume-app -- mongorestore /tmp/backup
```

### Persistent Volume Backups
- Enable automated backups in your cloud provider
- For AWS: Use EBS snapshots
- For GCP: Use Compute Engine snapshots
- For Azure: Use disk snapshots

## 8. Health Checks

### Backend Health Check
```bash
curl http://backend-service:5000/health
```

### Frontend Health Check
```bash
curl http://frontend-service/
```

### MongoDB Health Check
```bash
kubectl exec -it mongodb-0 -n resume-app -- mongosh --eval "db.adminCommand('ping')"
```

## 9. Troubleshooting

### Pod Not Starting
```bash
kubectl describe pod <pod-name> -n resume-app
kubectl logs <pod-name> -n resume-app
```

### Connection Issues
```bash
# Test DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup backend-service.resume-app.svc.cluster.local

# Test connectivity
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- curl http://backend-service:5000/health
```

### Storage Issues
```bash
kubectl get pvc -n resume-app
kubectl describe pvc mongodb-pvc -n resume-app
```

## 10. Rollback & Updates

### Rolling Update
```bash
# Update image
kubectl set image deployment/backend backend=sumitsingh00/resume-analysis-backend:v2 -n resume-app

# Check rollout status
kubectl rollout status deployment/backend -n resume-app

# Rollback if needed
kubectl rollout undo deployment/backend -n resume-app
```

## 11. Security Best Practices

- [ ] Use RBAC for access control
- [ ] Enable network policies
- [ ] Use secrets for sensitive data (not ConfigMaps)
- [ ] Implement pod security policies
- [ ] Regular security scanning
- [ ] Keep Kubernetes updated
- [ ] Use private container registries
- [ ] Implement resource quotas

## 12. Cost Optimization

- [ ] Set appropriate resource requests/limits
- [ ] Use spot instances for non-critical workloads
- [ ] Enable cluster autoscaling
- [ ] Regular cleanup of unused resources
- [ ] Monitor costs in your cloud provider

## Support

For issues or questions:
1. Check Kubernetes logs: `kubectl logs -f <pod-name> -n resume-app`
2. Review k8s README: `k8s/README.md`
3. Check GitHub issues: https://github.com/sumitsingh00/Resume-analysis-chat-bot/issues
