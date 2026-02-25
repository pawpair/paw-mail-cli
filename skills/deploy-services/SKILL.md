---
name: deploy-services
description: Deploy backend, client, and infrastructure services to the mail-client-mcp Kubernetes cluster
---

# Deploy Services Skill

Deploy backend, client, and infrastructure services to the mail-client-mcp Kubernetes cluster.

## When to Use This Skill

- User requests "deploy the backend" or "deploy backend service"
- User requests "deploy the client" or "deploy frontend"
- User requests "deploy all services" or "deploy everything"
- User requests "rebuild and deploy" or "update production"
- User needs to rollback a deployment

## ⚠️ SECURITY RULES - READ FIRST

**CRITICAL**: Never load, read, display, or mention any of the following:
- API keys, tokens, or credentials
- Kubernetes secrets (`kubectl get secret`)
- Environment variables containing sensitive data
- Database passwords or connection strings with credentials
- OAuth client secrets
- JWT signing keys
- Docker registry credentials
- Cloud provider access keys

**Safe Commands Only**:
- ✅ `kubectl get pods/deployments/services` (status only)
- ✅ `kubectl logs` (application logs, no secrets)
- ✅ `docker build/push` (uses stored credentials, doesn't expose them)
- ✅ `kubectl rollout restart` (uses existing secrets)

**Forbidden Commands**:
- ❌ `kubectl get secret` or `kubectl describe secret`
- ❌ `kubectl get configmap` (if contains credentials)
- ❌ Reading files in `infrastructure/k8s/**/sealed-secret.yaml`
- ❌ `echo $ENV_VAR` for any credential-related variables
- ❌ `cat` or `grep` on files containing credentials
- ❌ `kubectl exec` commands that print environment variables

**If the user asks to see secrets**: Politely refuse and explain that secrets should not be exposed in chat for security reasons. Suggest they access the cluster directly if needed.

## Service Architecture

### Backend Service
- **Path**: `services/backend`
- **Language**: Rust
- **Image**: `registry.digitalocean.com/mail-platform/backend:latest`
- **Ports**: gRPC :50051, HTTP :8080
- **Key Features**: Database migrations (auto-run), Istio auth, MCP server

### Client Service
- **Path**: `services/client`
- **Framework**: SvelteKit
- **Image**: `registry.digitalocean.com/mail-platform/mail-client:latest`
- **Port**: :3000
- **Dependencies**: `services/ui-lib` (must build first)

### UI Library
- **Path**: `services/ui-lib`
- **Type**: Web Components (Lit)
- **Output**: `dist/index.js`
- **Note**: Must be built before client

## Deployment Steps

### Deploy Backend
```bash
cd /home/dan/Code/mail-client-mcp
bazel build //services/backend:backend_tarball --config=release
docker load < bazel-bin/services/backend/backend_tarball/tarball.tar
doctl registry login
docker push registry.digitalocean.com/mail-platform/backend:latest
kubectl rollout restart deployment/backend -n mail
```

### Deploy Client
```bash
cd /home/dan/Code/mail-client-mcp
docker build -t registry.digitalocean.com/mail-platform/client:latest -f Dockerfile.client .
docker tag registry.digitalocean.com/mail-platform/client:latest registry.digitalocean.com/mail-platform/mail-client:latest
doctl registry login
docker push registry.digitalocean.com/mail-platform/mail-client:latest
kubectl rollout restart deployment/client -n mail
```

### Force Pod Restart (Resource Constraints)
```bash
# Single-node cluster requires manual pod deletion
kubectl delete pod -n mail -l app=backend
kubectl delete pod -n mail -l app=client
```

## Important Notes

### Image Naming
- Backend uses `backend:latest`
- Client deployment expects `mail-client:latest` but builds as `client:latest`
- **Always tag client image twice**: `client:latest` AND `mail-client:latest`

### Resource Management
- Cluster is single-node with limited resources
- Old pods may not terminate automatically
- Use `kubectl delete pod` to force resource cleanup

### Database Migrations
- Migrations run automatically on backend startup
- Located in `services/backend/shared/database/migrations/`
- Check logs: `kubectl logs -n mail -l app=backend --tail=50`

### Verification
```bash
# Check pod status
kubectl get pods -n mail

# Check backend health
curl https://mail-mcp.pawpair.pet/health

# Check client health
curl https://accounts.pawpair.pet/

# Verify migrations
kubectl exec -n mail statefulset/postgres -- psql -U ssohub -d ssohub -c "\dt"
```

## Common Issues

### ImagePullBackOff
**Fix**: Run `doctl registry login` before pushing images

### Pods Stuck Pending
**Reason**: Insufficient CPU/memory on single-node cluster
**Fix**: Delete old pods: `kubectl delete pod <old-pod-name> -n mail`

### Wrong Client Image
**Reason**: Deployment expects `mail-client:latest`
**Fix**: Tag image as both `client:latest` and `mail-client:latest`

### Database Errors
**Check**: `kubectl logs -n mail -l app=backend | grep migration`
**Fix**: Migrations auto-run, check for SQL errors in logs
