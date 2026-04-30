resource "google_compute_instance" "postgres_vm" {
  name                      = "iot-postgres-vm"
  machine_type              = var.postgres_vm_machine_type
  zone                      = var.zone
  tags                      = ["iot-postgres"]
  allow_stopping_for_update = true

  depends_on = [google_compute_router_nat.nat]

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

# API VM and other VMs in the subnet reach Postgres on the private IP (same model as docker-compose on one LAN).
resource "google_compute_firewall" "postgres_ingress" {
  name    = "allow-postgres-from-vpc-subnet"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = [google_compute_subnetwork.subnet.ip_cidr_range]
  target_tags   = ["iot-postgres"]
}

