# Name: vm.tf
# Owner: Saurav Mitra
# Description: This terraform config will create a VM Instance as Nginx Webserver

# Public IP
resource "google_compute_address" "web_public_ip" {
  project      = var.project_id
  region       = var.region
  name         = "${var.prefix}-web-public-ip"
  description  = "${var.prefix}-web-public-ip"
  address_type = "EXTERNAL"
}

# VM Instance
resource "google_compute_instance" "web_instance" {
  name         = "${var.prefix}-web-instance"
  description  = "${var.prefix}-web-instance"
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["web"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  metadata_startup_script = file("webserver.sh")

  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.public_subnets[0].name
    access_config {
      nat_ip = google_compute_address.web_public_ip.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}
