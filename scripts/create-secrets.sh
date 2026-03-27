#!/bin/bash
set -euo pipefail

# ============================================
# Create Kubernetes secrets for Esprit Market
# ============================================

NAMESPACE="esprit-market"

echo "=== Creating namespace ==="
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "=== Creating secrets ==="
echo "Enter values for secrets:"

read -sp "PostgreSQL Password: " POSTGRES_PASSWORD
echo ""
read -sp "JWT Secret (at least 32 chars): " JWT_SECRET
echo ""
read -p "Google Maps API Key (optional, press enter to skip): " GOOGLE_MAPS_API_KEY
echo ""

kubectl create secret generic backend-secret \
  --namespace=$NAMESPACE \
  --from-literal=SPRING_DATASOURCE_PASSWORD="$POSTGRES_PASSWORD" \
  --from-literal=JWT_SECRET="$JWT_SECRET" \
  --from-literal=GOOGLE_MAPS_API_KEY="${GOOGLE_MAPS_API_KEY:-}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "=== Secrets created successfully ==="
