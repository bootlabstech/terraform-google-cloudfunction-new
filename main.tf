provider "google" {
  project = var.project_id
  region  = var.bucket_location
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create the storage bucket
resource "google_storage_bucket" "bucket" {
  name     = "${var.bucket_name_prefix}-${random_id.bucket_suffix.hex}"
  project  = var.project_id
  location = var.bucket_location
  uniform_bucket_level_access = true
}

# Upload the source code zip (e.g., contains main.py)
resource "google_storage_bucket_object" "source" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "function-source.zip" # This zip must exist locally and contain main.py
}

# Deploy Cloud Function 2nd Gen
resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  project     = var.project_id
  location    = var.bucket_location

  build_config {
    runtime     = var.environment_runtime
    entry_point = var.entry_point

    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.source.name
      }
    }
  }

 service_config {
    max_instance_count            = var.max_instance_count
    available_memory              = var.available_memory
    timeout_seconds               = var.timeout_seconds
    vpc_connector                 = var.vpc_connector
    vpc_connector_egress_settings = var.vpc_connector_egress_settings
    ingress_settings              = var.ingress_settings

    environment_variables = {
      GOOGLE_FUNCTION_SOURCE = "main.py"
    }
  }
     lifecycle {
    ignore_changes = [
      build_config
    ]
  }
}