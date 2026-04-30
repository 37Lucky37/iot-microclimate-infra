# Grafana VM: Runs Grafana in Docker with access to the database.

locals {
  grafana_database_url = "postgres://${urlencode(var.db_user)}:${urlencode(var.db_password)}@${google_compute_instance.postgres_vm.network_interface[0].network_ip}:5432/${urlencode(var.db_name)}"
}

resource "google_compute_instance" "grafana_vm" {
  name         = "iot-grafana-vm"
  machine_type = var.grafana_vm_machine_type
  zone         = var.zone
  tags         = ["iot-grafana"]

  depends_on = [google_compute_instance.postgres_vm]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {}
  }

  # Needed to pull images if required.
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    "startup-script" = replace(<<-EOT
#!/bin/bash
set -euxo pipefail

apt-get update
apt-get install -y docker.io curl gnupg ca-certificates
systemctl enable docker
systemctl start docker

# Create Grafana data directory
mkdir -p /opt/grafana-data
chown -R 472:472 /opt/grafana-data
chmod -R 775 /opt/grafana-data

# Run Grafana
docker rm -f iot_microclimate_grafana || true
docker pull grafana/grafana:latest

docker run -d \
  --name iot_microclimate_grafana \
  --restart unless-stopped \
  -p 3000:3000 \
  -v /opt/grafana-data:/var/lib/grafana \
  -e GF_DATABASE_URL='${local.grafana_database_url}' \
  -e GF_SECURITY_ADMIN_PASSWORD='${var.grafana_admin_password}' \
  grafana/grafana:latest
EOT
    , "\r", "")
  }
}

resource "google_compute_firewall" "grafana_http" {
  name    = "allow-grafana-http"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = [var.grafana_http_ingress_cidr]
  target_tags   = ["iot-grafana"]
}