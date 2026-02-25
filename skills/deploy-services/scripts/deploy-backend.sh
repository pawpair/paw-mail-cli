#!/bin/bash
set -e

# SECURITY: This script uses stored credentials only
# It never prints secrets, tokens, or sensitive environment variables

REPO_ROOT="/home/dan/Code/mail-client-mcp"
REGISTRY="registry.digitalocean.com/mail-platform"
K8S_DIR="$REPO_ROOT/infrastructure/k8s/backend"
SHA=$(git -C "$REPO_ROOT" rev-parse --short=7 HEAD)

# Component -> K8s deployment manifest mapping
declare -A COMPONENTS=(
  [http]="deployment-http.yaml"
  [grpc]="deployment-grpc.yaml"
  [worker]="deployment-sync-worker.yaml"
  [scheduler]="deployment-sync-scheduler.yaml"
  [embedding]="deployment-embedding-worker.yaml"
)

# Component -> Dockerfile mapping
declare -A DOCKERFILES=(
  [http]="Dockerfile.http"
  [grpc]="Dockerfile.grpc"
  [worker]="Dockerfile.sync-worker"
  [scheduler]="Dockerfile.sync-scheduler"
  [embedding]="Dockerfile.embedding-worker"
)

# Parse args: specific components or all
if [ $# -gt 0 ]; then
  TARGETS=("$@")
else
  TARGETS=("${!COMPONENTS[@]}")
fi

cd "$REPO_ROOT"

echo "🔑 Logging into registry..."
doctl registry login

for comp in "${TARGETS[@]}"; do
  dockerfile="${DOCKERFILES[$comp]}"
  manifest="${COMPONENTS[$comp]}"
  tag="$REGISTRY/backend:${comp}-${SHA}"

  if [ -z "$dockerfile" ]; then
    echo "❌ Unknown component: $comp"
    exit 1
  fi

  echo ""
  echo "🔨 Building $comp ($dockerfile)..."
  docker build -f "services/backend/$dockerfile" -t "$tag" .

  echo "📤 Pushing $tag..."
  docker push "$tag"

  echo "📝 Updating $manifest with tag ${comp}-${SHA}..."
  sed -i "s|image: .*/backend:${comp}-.*|image: ${tag}|" "$K8S_DIR/$manifest"

  echo "🚀 Applying $manifest..."
  kubectl apply -f "$K8S_DIR/$manifest"
done

echo ""
echo "⏳ Waiting for rollout..."
for comp in "${TARGETS[@]}"; do
  case "$comp" in
    http)      kubectl rollout status deployment/backend-http -n mail --timeout=120s ;;
    grpc)      kubectl rollout status deployment/backend-grpc -n mail --timeout=120s ;;
    worker)    kubectl rollout status deployment/sync-worker -n mail --timeout=120s ;;
    scheduler) kubectl rollout status deployment/sync-scheduler -n mail --timeout=120s ;;
    embedding) kubectl rollout status deployment/embedding-worker -n mail --timeout=120s ;;
  esac
done

echo ""
echo "📊 Pod status:"
kubectl get pods -n mail

echo ""
echo "✅ Backend deployment complete (SHA: $SHA)"
