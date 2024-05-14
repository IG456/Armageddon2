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
  region      = "europe-west1"
  zone        = "europe-west1-b"

}

resource "google_compute_network" "task3-vpc-network2" {
  name = "task3-vpc-network2"
auto_create_subnetworks = false
}

resource "google_compute_network" "task3-vpc-network3" {
  name = "task3-vpc-network3"
auto_create_subnetworks = false
}

resource "google_compute_network" "task3-vpc-network4" {
  name = "task3-vpc-network4"
auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "europe-west1" {
  name          = "europe-west1"
  network       = google_compute_network.task3-vpc-network2.id
  ip_cidr_range = "10.20.0.0/24"
  region        = "europe-west1"
private_ip_google_access = true

}

resource "google_compute_firewall" "subnet-firewall" {
  name    = "subnet-firewall"
  network = google_compute_network.task3-vpc-network2.name


  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

  source_ranges = ["10.20.0.0/24", "172.16.135.0/24", "172.16.140.0/24", "192.168.90.0/24"]
target_tags = ["europe", "america", "asia"]

}


resource "google_compute_instance" "task3-compute-instance" {
 name         = "task3-compute-instance"
 machine_type = "n1-standard-1"
 zone         = "europe-west1-b"


 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-11"
   }
 }

 network_interface {
   network = google_compute_network.task3-vpc-network2.name
subnetwork = google_compute_subnetwork.europe-west1.name

   access_config {
     // Ephemeral IP
   }
 }


 tags = ["europe"]


  metadata = {
    startup-script = "#Thanks to Remo\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome to your custom website.</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }
}

resource "google_compute_subnetwork" "us-east1" {
  name          = "us-east1"
  network       = google_compute_network.task3-vpc-network3.id
  ip_cidr_range = "172.16.135.0/24"
  region        = "us-east1"
private_ip_google_access = true

}

resource "google_compute_subnetwork" "us-east4" {
  name          = "us-east4"
  network       = google_compute_network.task3-vpc-network3.id
  ip_cidr_range = "172.16.140.0/24"
  region        = "us-east4"
private_ip_google_access = true

}

resource "google_compute_firewall" "subnet-firewall2" {
  name    = "subnet-firewall2"
  network = google_compute_network.task3-vpc-network3.name


  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

  source_ranges = ["0.0.0.0/0", "35.235.240.0/20"]
target_tags = ["america", "ssh"]

}

resource "google_compute_instance" "task3-compute-instance2" {
 name         = "task3-compute-instance2"
 machine_type = "n1-standard-1"
 zone         = "us-east1-b"
 depends_on = [ google_compute_subnetwork.us-east1 ]


 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-11"
   }
 }

 network_interface {
   network = google_compute_network.task3-vpc-network3.name
subnetwork = google_compute_subnetwork.us-east1.name

   access_config {
     // Ephemeral IP
   }
 }


 tags = ["america", "ssh"]


  metadata = {
    startup-script = "#Thanks to Remo\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome to your custom website.</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }
}


resource "google_compute_instance" "task3-compute-instance3" {
 name         = "task3-compute-instance3"
 machine_type = "n1-standard-1"
 zone         = "us-east4-a"
 depends_on = [ google_compute_subnetwork.us-east4 ]


 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-11"
   }
 }

 network_interface {
   network = google_compute_network.task3-vpc-network3.name
subnetwork = google_compute_subnetwork.us-east4.name

   access_config {
     // Ephemeral IP
   }
 }


 tags = ["america", "ssh"]


  metadata = {
    startup-script = "#Thanks to Remo\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome to your custom website.</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }
}

resource "google_compute_network_peering" "peering1-europe-america" {
  name         = "peering1-europe-america"
  network      = google_compute_network.task3-vpc-network2.id
  peer_network = google_compute_network.task3-vpc-network3.id
}

resource "google_compute_network_peering" "peering2-america-europe" {
  name         = "peering2-america-europe"
  network      = google_compute_network.task3-vpc-network3.id
  peer_network = google_compute_network.task3-vpc-network2.id
}

resource "google_compute_subnetwork" "asia-east1" {
  name          = "asia-east1"
  network       = google_compute_network.task3-vpc-network4.id
  ip_cidr_range = "192.168.90.0/24"
  region        = "asia-east1"
private_ip_google_access = true

}

resource "google_compute_firewall" "subnet-firewall3" {
  name    = "subnet-firewall3"
  network = google_compute_network.task3-vpc-network4.name


  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
target_tags = ["asia"]

}

resource "google_compute_instance" "task3-compute-instance4" {
 name         = "task3-compute-instance4"
 machine_type = "n1-standard-1"
 zone         = "asia-east1-a"
 depends_on = [ google_compute_subnetwork.asia-east1 ]


 boot_disk {
   initialize_params {
     image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
    #  image = "debian-cloud/debian-11"
   }
 }

 network_interface {
   network = google_compute_network.task3-vpc-network4.name
subnetwork = google_compute_subnetwork.asia-east1.name

   access_config {
     // Ephemeral IP
   }
 }


 tags = ["asia"]


  metadata = {
    startup-script = "#Thanks to Remo\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome to your custom website.</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }
}


# VPN GATEWAY AND TUNNELING-
# EUROPE GATEWAY
resource "google_compute_vpn_gateway" "europe_vpn_gateway" {
 name    = "europe-vpn-gateway"
 network = google_compute_network.task3-vpc-network2.id
 region  = "europe-west1"
}


# ASIA GATEWAY
resource "google_compute_vpn_gateway" "asia_vpn_gateway" {
 name    = "asia-vpn-gateway"
 network = google_compute_network.task3-vpc-network4.id
 region  = "asia-east1"
}


# EXTERNAL STATIC IP ADDRESS FOR VPN GATEWAYS
resource "google_compute_address" "europe_vpn_ip" {
 name   = "europe-vpn-ip"
 region = "europe-west1"
}


resource "google_compute_address" "asia_vpn_ip" {
 name   = "asia-vpn-ip"
 region = "asia-east1"
}

resource "google_compute_vpn_tunnel" "asia_to_europe_tunnel" {
 name               = "asia-to-europe-tunnel"
 region             = "asia-east1"
 target_vpn_gateway = google_compute_vpn_gateway.asia_vpn_gateway.id
 peer_ip            = google_compute_address.europe_vpn_ip.address
 shared_secret = "secret-"
 ike_version   = 2


 local_traffic_selector  = ["192.168.90.0/24"]
 remote_traffic_selector = ["10.20.0.0/24"]


 depends_on = [
   google_compute_forwarding_rule.asia_esp,
   google_compute_forwarding_rule.asia_udp500,
   google_compute_forwarding_rule.asia_udp4500,
 ]
}


# ROUTE FOR ASIA TO EUROPE
resource "google_compute_route" "asia_to_europe_route" {
 name                = "asia-to-europe-route"
 network             = google_compute_network.task3-vpc-network4.id
 dest_range          = "10.20.0.0/24"
 next_hop_vpn_tunnel = google_compute_vpn_tunnel.asia_to_europe_tunnel.id
 priority            = 1000
}

# FORWARDING RULES FOR THE ASIA VPN
resource "google_compute_forwarding_rule" "asia_esp" {
 name        = "asia-esp"
 region      = "asia-east1"
 ip_protocol = "ESP"
 ip_address  = google_compute_address.asia_vpn_ip.address
 target      = google_compute_vpn_gateway.asia_vpn_gateway.self_link
}

resource "google_compute_forwarding_rule" "asia_udp500" {
 name        = "asia-udp500"
 region      = "asia-east1"
 ip_protocol = "UDP"
 ip_address  = google_compute_address.asia_vpn_ip.address
 port_range  = "500"
 target      = google_compute_vpn_gateway.asia_vpn_gateway.self_link
}

resource "google_compute_forwarding_rule" "asia_udp4500" {
 name        = "asia-udp4500"
 region      = "asia-east1"
 ip_protocol = "UDP"
 ip_address  = google_compute_address.asia_vpn_ip.address
 port_range  = "4500"
 target      = google_compute_vpn_gateway.asia_vpn_gateway.self_link
}

#REVERSE VPN TUNNEL FROM EUROPE TO ASIA
resource "google_compute_vpn_tunnel" "europe_to_asia_tunnel" {
 name               = "europe-to-asia-tunnel"
 region             = "europe-west1"
 target_vpn_gateway = google_compute_vpn_gateway.europe_vpn_gateway.id
 peer_ip            = google_compute_address.asia_vpn_ip.address
 shared_secret = "secret-"
 ike_version   = 2


 local_traffic_selector  = ["10.20.0.0/24"]
 remote_traffic_selector = ["192.168.90.0/24"]


 depends_on = [
   google_compute_forwarding_rule.europe_esp,
   google_compute_forwarding_rule.europe_udp500,
   google_compute_forwarding_rule.europe_udp4500,
 ]
}

# ROUTE FOR EUROPE TO ASIA
resource "google_compute_route" "europe_to_asia_route" {
 depends_on          = [google_compute_vpn_tunnel.europe_to_asia_tunnel]
 name                = "europe-to-asia-route"
 network             = google_compute_network.task3-vpc-network2.id
 dest_range          = "192.168.90.0/24"
 next_hop_vpn_tunnel = google_compute_vpn_tunnel.europe_to_asia_tunnel.id
}

# FORWARDING RULES FOR EUROPE VPN
resource "google_compute_forwarding_rule" "europe_esp" {
 name        = "europe-esp"
 region      = "europe-west1"
 ip_protocol = "ESP"
 ip_address  = google_compute_address.europe_vpn_ip.address
 target      = google_compute_vpn_gateway.europe_vpn_gateway.self_link
}

resource "google_compute_forwarding_rule" "europe_udp500" {
 name        = "europe-udp500"
 region      = "europe-west1"
 ip_protocol = "UDP"
 ip_address  = google_compute_address.europe_vpn_ip.address
 port_range  = "500"
 target      = google_compute_vpn_gateway.europe_vpn_gateway.self_link
}

resource "google_compute_forwarding_rule" "europe_udp4500" {
 name        = "europe-udp4500"
 region      = "europe-west1"
 ip_protocol = "UDP"
 ip_address  = google_compute_address.europe_vpn_ip.address
 port_range  = "4500"
 target      = google_compute_vpn_gateway.europe_vpn_gateway.self_link
}

resource "google_compute_firewall" "subnet-firewall4" {
  name    = "subnet-firewall4"
  network = google_compute_network.task3-vpc-network2.name


  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  allow {
    protocol = "icmp"

  }
  
  source_ranges = ["192.168.90.0/24"]
target_tags = ["europe"]

}