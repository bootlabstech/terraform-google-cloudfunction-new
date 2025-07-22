provider "google" {
  project = var.project_id
  region  = var.bucket_location
}

resource "google_cloudfunctions_function" "function" {
  name        = var.function_name
  runtime     = var.environment_runtime
  region      = var.bucket_location
  project     = var.project_id
  entry_point = var.entry_point

  # Reference existing bucket/object
  source_archive_bucket = var.existing_bucket_name
  source_archive_object = var.existing_object_name

  trigger_http = true

  available_memory_mb = var.available_memory
  timeout             = var.timeout_seconds

  # Optional VPC access
  vpc_connector                  = var.vpc_connector
  vpc_connector_egress_settings = var.vpc_connector_egress_settings
  ingress_settings              = var.ingress_settings

  environment_variables = {
    GOOGLE_FUNCTION_SOURCE="main.py"
  }
   lifecycle {
    ignore_changes = [
      entry_point,
      source_archive_bucket,
      source_archive_object
    ]
  }
}

# (Optional) Allow unauthenticated invocations
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = var.bucket_location
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
