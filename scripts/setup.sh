#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 Starting crac-local GitOps environment setup..."

# Check prerequisites
echo "🔍 Checking prerequisites..."
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed."; exit 1; }
command -v kind >/dev/null 2>&1 || { echo "❌ Kind is required but not installed."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed."; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "❌ Helm is required but not installed."; exit 1; }
echo "✅ All prerequisites met!"

# Create Kind cluster
echo "📦 Creating Kind cluster 'crac-local'..."
if kind get clusters | grep -q "crac-local"; then
    echo "⚠️  Cluster 'crac-local' already exists. Deleting..."
    kind delete cluster --name crac-local
fi
kind create cluster --config "$PROJECT_ROOT/kind/kind-config.yaml"
echo "✅ Kind cluster created!"

# Wait for cluster to be ready
echo "⏳ Waiting for cluster nodes to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s
echo "✅ All nodes are ready!"

# Create namespaces
echo "📁 Creating namespaces..."
kubectl apply -f "$PROJECT_ROOT/argocd/namespace.yaml"
echo "✅ Namespaces created!"

# Install ArgoCD
echo "🔧 Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "✅ ArgoCD manifests applied!"

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD server to be ready..."
kubectl wait --for=condition=Available deployment/argocd-server -n argocd --timeout=300s
echo "✅ ArgoCD server is ready!"

# Patch ArgoCD service to NodePort
echo "🔧 Configuring ArgoCD service as NodePort..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort", "ports": [{"port": 443, "targetPort": 8080, "nodePort": 30080}]}}'
echo "✅ ArgoCD service patched!"

# Wait a bit for the service to be ready
sleep 5

# Get ArgoCD password
echo "🔑 Retrieving ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "=========================================="
echo "🎉 Setup Complete!"
echo "=========================================="
echo ""
echo "📊 ArgoCD Dashboard:"
echo "   URL: https://localhost:30080"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASSWORD"
echo ""
echo "🌐 Sample App (after deployment):"
echo "   URL: http://localhost:30000"
echo ""
echo "📝 Next Steps:"
echo "   1. Update argocd/applications/sample-app.yaml with your Git repo URL"
echo "   2. Apply the ArgoCD application:"
echo "      kubectl apply -f argocd/applications/sample-app.yaml"
echo "   3. Or deploy manually with Helm:"
echo "      helm install sample-app helm-charts/sample-app -n sample"
echo ""
echo "🛠️  Useful Commands:"
echo "   kubectl get pods -A              # View all pods"
echo "   kubectl get nodes                # View cluster nodes"
echo "   ./scripts/teardown.sh            # Delete the cluster"
echo "=========================================="
