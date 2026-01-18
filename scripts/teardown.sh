#!/bin/bash
set -e

echo "🗑️  Tearing down crac-local GitOps environment..."

# Delete Kind cluster
if kind get clusters | grep -q "crac-local"; then
    echo "📦 Deleting Kind cluster 'crac-local'..."
    kind delete cluster --name crac-local
    echo "✅ Cluster deleted!"
else
    echo "⚠️  Cluster 'crac-local' not found. Nothing to delete."
fi

echo ""
echo "=========================================="
echo "🎉 Teardown Complete!"
echo "=========================================="
