# 2025 GCP Demo: Go Pub/Sub Microservice

A sample end‑to‑end service showing how to build, deploy, and operate a **Go**‑based money‑transfer microservice on Google Cloud:

- **gRPC API** for processing transfers  
- **Cloud Pub/Sub** for asynchronous audit‑event publishing  
- **Cloud SQL (PostgreSQL)** for ledger persistence  
- **GKE** (Kubernetes) to run the service behind a LoadBalancer  
- **Terraform** for infrastructure as code  
- **GitHub Actions** + **Docker** for CI/CD  

---

## 🚀 Built So Far

1. **gRPC Definition & Codegen**  
   - `transfer.proto` with `go_package` option → Go stubs generated under `go-server-demo/transfer/`  
2. **Go Transfer Service** (`cmd/server`)  
   - `ProcessTransfer` handler does currency conversion stub, ACID DB transaction, and publishes audit events to Pub/Sub  
3. **Pub/Sub Infrastructure** (`terraform/pubsub.tf`)  
   - Topic `audit-events`, DLQ topic `audit-events-dlq`, subscription `audit-events-sub` with dead‑letter policy and 7 day retention  
4. **GKE Deployment & Service** (`terraform/deployment.tf`)  
   - Kubernetes Deployment (2 replicas) listening on port 50051 + LoadBalancer Service exposing port 50051  
5. **Cloud SQL** (`terraform/cloud_sql.tf`)  
   - PostgreSQL 17 instance, database `ledger`, user `transfer_user` on a supported `db-custom-1-3840` tier  
6. **CI/CD Pipeline** (`.github/workflows/ci-cd.yml`)  
   - Regenerates protobuf code, builds & pushes Docker image to GCR, runs Terraform to provision infra and deploy  

---

## 🔮 What’s Next

We set out to build a **high‑throughput money‑transfer platform** leveraging Go’s concurrency, crypto rails, and event‑driven audit logs. On deck:

1. **Massive Parallel Transfers**  
   - Use Go goroutines and channels to fan out thousands of concurrent transfers per second.  
   - Implement worker pools that back‑pressure on Pub/Sub backlog and coordinate idempotent retries.

2. **Crypto‑Backend Integration**  
   - Extend `ProcessTransfer` to route funds over a blockchain rail:  
     - Sign transactions via GCP KMS or HSM  
     - Broadcast on‑chain, await confirmations  
     - Convert between fiat ↔ crypto using real‑time oracles before ledger commit

3. **Advanced Audit & Analytics**  
   - Build a dedicated subscriber (e.g. in Go or .NET) that consumes `audit-events-sub` and persists to TimescaleDB or BigQuery.  
   - Add dashboards and alerts on transfer volumes, failures, and anomalous patterns.

4. **Resiliency & Auto‑Scaling**  
   - Configure Horizontal Pod Autoscalers based on custom Pub/Sub metrics or gRPC latency.  
   - Chaos‑test failure paths (DB timeouts, Pub/Sub nacks) and verify self‑healing.

5. **Multi‑Environment & GitOps**  
   - Split Terraform into **dev**, **staging**, and **prod** workspaces or use Terragrunt  
   - Adopt a GitOps tool (Argo CD) so infrastructure changes self‑deploy on PR merge

---

## 🏁 Getting Started

### Prerequisites

- Go ≥ 1.24  
- `protoc` compiler  
- `gcloud` SDK  
- Terraform ≥ 1.5.0  
- Docker  

### Quick Commands

#### 1. Generate gRPC code locally

```bash
cd go-server-demo
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
mkdir -p transfer
protoc \
  --go_out=transfer --go_opt=paths=source_relative \
  --go-grpc_out=transfer --go-grpc_opt=paths=source_relative \
  transfer.proto
```

#### 2. Run the server locally

```bash
# (Optional) start Cloud SQL Proxy if using Cloud SQL:
#   cloud-sql-proxy YOUR_INSTANCE_CONN=tcp:5432

export GOOGLE_APPLICATION_CREDENTIALS="../gcp-demo-460104-*.json"
export LEDGER_DSN="postgres://transfer_user:<PASSWORD>@127.0.0.1:5432/ledger?sslmode=disable"

cd go-server-demo
go run cmd/server
```

#### 3. Test with the example client
```bash
cd go-server-demo
go run cmd/client --addr localhost:50051
4. Deploy via CI/CD
Push to main and let GitHub Actions:

Regenerate protobuf

Build & push Docker image

Provision infra with Terraform

Deploy to GKE

5. Inspect the live service
```

# Fetch Kube credentials
```bash
gcloud container clusters get-credentials gcp-demo-cluster \
  --region us-central1 --project YOUR_PROJECT_ID
```

# Get the LoadBalancer IP
```bash
kubectl get svc go-server-demo -o wide
```
# Call with grpcurl
```
grpcurl -plaintext <EXTERNAL_IP>:50051 list
```


### Docker commands
```
docker build -t gcr.io/gcp-demo-460104/go-server-demo:v2 .
docker push gcr.io/gcp-demo-460104/go-server-demo:v2
```

## GCP commands
pull messages command
```
gcloud pubsub subscriptions tail audit-events-sub \
  --project=gcp-demo-460104 \
  --format="json(message.message.data)"
```