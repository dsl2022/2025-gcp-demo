# 2025-gcp-demo



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