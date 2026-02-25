#!/bin/bash
set -e

# SECURITY: This script uses stored credentials only
# It never prints secrets, tokens, or sensitive environment variables

echo "🚀 Deploying all services..."
echo ""

# Deploy backend
echo "================================================"
echo "1/2 Deploying Backend"
echo "================================================"
./skills/deploy-services/scripts/deploy-backend.sh

echo ""
echo "================================================"
echo "2/2 Deploying Client"
echo "================================================"
./skills/deploy-services/scripts/deploy-client.sh

echo ""
echo "================================================"
echo "✅ All services deployed"
echo "================================================"
echo ""
echo "Verification:"
echo "  Backend: https://mail-mcp.pawpair.pet/health"
echo "  Client:  https://accounts.pawpair.pet/"
