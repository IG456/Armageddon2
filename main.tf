terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = "project12-420602-dd8250ea414a.json"
  project     = "project12-420602"
  region      = "us-central1"
  zone        = "us-central1-a"
}

resource "google_storage_bucket" "bucket" {
  name          = "arma1"
  location      = "EU"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "error.html"
  }

  uniform_bucket_level_access = false
}

resource "google_storage_bucket_object" "upload_html" {
  for_each     = fileset("${path.module}/", "*.html")
  bucket       = google_storage_bucket.bucket.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "text/html"

}

resource "google_storage_bucket_acl" "bucket_acl" {
  bucket         = google_storage_bucket.bucket.name
  predefined_acl = "publicRead"
}

output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.bucket.name}/index.html"
}