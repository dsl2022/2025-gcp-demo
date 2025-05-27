


resource "google_sql_database_instance" "postgres" {
  provider            = google-beta
  depends_on = [
    google_project_service.sqladmin
  ]
  project          = var.project_id
  name             = var.db_instance_name
  region           = var.region
  database_version = "POSTGRES_17"
  deletion_protection = false
  settings {
    tier            = "db-perf-optimized-N-2"
    disk_size       = 10
    disk_type       = "PD_SSD"
    backup_configuration {
      enabled = true
    }
    ip_configuration {
      ipv4_enabled    = true
      # optional: restrict to your CIDR  
      # authorized_networks = [{ value = "YOUR_IP/32" }]
    }
  }
}

resource "google_sql_database" "ledger" {
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
  name     = var.db_database_name
}

resource "google_sql_user" "app_user" {
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
  name     = var.db_username
  password = var.db_password
}
