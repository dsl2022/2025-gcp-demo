#!/usr/bin/env bash
PROJECT="gcp-demo-460104"
SUB="audit-events-sub"

OUTPUT=$(gcloud pubsub subscriptions pull "$SUB" \
  --project="$PROJECT" \
  --limit=1 \
  --format="json(ackId,message.data)")

if [ -z "$OUTPUT" ] || [ "$OUTPUT" = "[]" ]; then
  echo "🚫 No messages available in $SUB"
  exit 0
fi

ACK_ID=$(echo "$OUTPUT" | jq -r '.[0].ackId')
MSG=$(echo    "$OUTPUT" | jq -r '.[0].message.data')

echo "$MSG" | base64 --decode | jq

gcloud pubsub subscriptions ack "$SUB" \
  --project="$PROJECT" \
  --ack-ids="$ACK_ID"
