
resource "google_project_service" "cloudbuild" {
  provider           = google-beta
  project            = var.project_id
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloudfunctions2_function" "function" {
  name =var.function_name
  location = var.bucket_location
  project            = var.project_id

  build_config {
    runtime = var.environment_runtime
    entry_point = var.entry_point  # Set the entry point 
    source {
      storage_source {
        bucket = var.existing_bucket_name
        object = var.existing_object_name
      }
    }
    
  }

  service_config {
    max_instance_count  = var.max_instance_count
    available_memory    = var.available_memory
    timeout_seconds     = var.timeout_seconds
    ingress_settings = var.ingress_settings
    vpc_connector = var.vpc_connector
    vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
  
  }
  
}
 