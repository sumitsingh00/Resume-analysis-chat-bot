#!/bin/bash

# Kubernetes Cleanup Script
# Usage: ./k8s-cleanup.sh

set -e

NAMESPACE="resume-app"

echo "========================================"
echo "Cleaning up Kubernetes Resources"
echo "========================================"

read -p "Are you sure you want to delete all resources in $NAMESPACE? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted"
    exit 1
fi

echo ""
echo "Deleting all resources in namespace: $NAMESPACE"
kubectl delete namespace $NAMESPACE

echo "✓ Cleanup complete"
echo ""
echo "All resources have been deleted."
