#!/bin/bash
set -e

echo "🔑 Retrieving ArgoCD admin password..."

# Check if cluster exists
if ! kind get clusters | grep -q "crac-local"; then
    echo "❌ Cluster 'crac-local' not found. Run setup.sh first."
    exit 1
fi

# Check if secret exists
if ! kubectl -n argocd get secret argocd-initial-admin-secret &>/dev/null; then
    echo "❌ ArgoCD initial admin secret not found."
    echo "   The password may have been changed or ArgoCD is not installed."
    exit 1
fi

ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "=========================================="
echo "🔐 ArgoCD Credentials"
echo "=========================================="
echo "   Username: admin"
echo "   Password: $ARGOCD_PASSWORD"
echo "   URL: https://localhost:30080"
echo "=========================================="
