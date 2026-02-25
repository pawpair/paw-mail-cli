#!/bin/bash
set -e

# SECURITY: This script uses stored credentials only
# It never prints secrets, tokens, or sensitive environment variables

echo "🔨 Building client Docker image..."
cd /home/dan/Code/mail-client-mcp
docker build -t registry.digitalocean.com/mail-platform/client:latest -f Dockerfile.client .

echo "🏷️  Tagging image as mail-client..."
docker tag registry.digitalocean.com/mail-platform/client:latest registry.digitalocean.com/mail-platform/mail-client:latest

echo "🔑 Logging into registry..."
doctl registry login

echo "📤 Pushing images..."
docker push registry.digitalocean.com/mail-platform/client:latest
docker push registry.digitalocean.com/mail-platform/mail-client:latest

echo "🚀 Restarting deployment..."
kubectl rollout restart deployment/client -n mail

echo "⏳ Waiting for deployment..."
sleep 10

echo "📊 Pod status:"
kubectl get pods -n mail -l app=client

echo "✅ Client deployment initiated"
