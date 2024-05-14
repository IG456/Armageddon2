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


resource "google_compute_network" "task2-vpc-network" {
 name                    = "task2-vpc-network"
 auto_create_subnetworks = "true"
}


resource "google_compute_firewall" "task2-allow-http" {
 name    = "task2-allow-http"
 network = google_compute_network.task2-vpc-network.name


 allow {
   protocol = "tcp"
   ports    = ["80"]
 }


 source_ranges = ["0.0.0.0/0"]
 target_tags   = ["http-server"]
}


# SETTING UP THE VM
resource "google_compute_instance" "task2-compute-instance" {
 name         = "task2-compute-instance"
 machine_type = "n1-standard-1"
 zone         = "us-east1-d"


 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-11"
   }
 }

 network_interface {
   network = google_compute_network.task2-vpc-network.name


   access_config {
     // Ephemeral IP
   }
 }


 tags = ["http-server", "https-server"]


  metadata = {
    startup-script = "#Thanks to Remo\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome to your custom website.</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }
}


# PUBLIC IP ADDRESS OF THE VPC
output "public_ip" {
 value = google_compute_instance.task2-compute-instance.network_interface[0].access_config[0].nat_ip
}


# VPC ID
output "vpc-id" {
 value = google_compute_network.task2-vpc-network.id
}


# SUBNET OF THE VM INSTANCE
output "subnet" {
 value = google_compute_instance.task2-compute-instance.network_interface[0].subnetwork
}


# INTERNAL IP ADDRESS OF THE VM INSTANCE
output "internal_ip" {
 value = google_compute_instance.task2-compute-instance.network_interface[0].network_ip
}