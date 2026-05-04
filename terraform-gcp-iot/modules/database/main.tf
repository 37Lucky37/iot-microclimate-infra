resource "google_compute_instance" "postgres_vm" {
  name                      = var.vm_name
  machine_type              = var.machine_type
  zone                      = var.zone
  tags                      = var.tags
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.disk_image
      size  = var.disk_size
      type  = var.disk_type
    }
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.subnet_id
  }

  metadata = {
    "startup-script" = replace(<<-EOT
#!/bin/bash
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y docker.io curl gnupg ca-certificates
systemctl enable docker
systemctl start docker

docker rm -f iot_microclimate_db || true
docker pull timescale/timescaledb:latest-pg15

docker run -d \
  --name iot_microclimate_db \
  --restart unless-stopped \
  -e POSTGRES_USER='${var.db_user}' \
  -e POSTGRES_PASSWORD='${var.db_password}' \
  -e POSTGRES_DB='${var.db_name}' \
  -p 5432:5432 \
  -v /opt/timescale-data:/var/lib/postgresql/data \
  timescale/timescaledb:latest-pg15
EOT
    , "\r", "")
  }
}

resource "google_compute_firewall" "postgres_ingress" {
  name    = var.firewall_name
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = [var.subnet_cidr]
  target_tags   = var.tags
}