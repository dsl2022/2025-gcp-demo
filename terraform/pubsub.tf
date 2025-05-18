resource "google_pubsub_topic" "audit_events" {
  name    = "audit-events"
  project = var.project_id
}

resource "google_pubsub_topic" "audit_events_dlq" {
  name    = "audit-events-dlq"
  project = var.project_id
}

resource "google_pubsub_subscription" "audit_events_sub" {
  name  = "audit-events-sub"
  topic = google_pubsub_topic.audit_events.name
  ack_deadline_seconds = 30
  dead_letter_policy {
    dead_letter_topic       = google_pubsub_topic.audit_events_dlq.id
    max_delivery_attempts   = 5
  }
  message_retention_duration = "168h"  # 7 days
}
