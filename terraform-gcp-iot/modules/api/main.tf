locals {
  api_database_url = "postgresql+asyncpg://${urlencode(var.db_user)}:${urlencode(var.db_password)}@${var.db_private_ip}:5432/${urlencode(var.db_name)}"
}

resource "google_compute_instance" "api_vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = var.tags

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

    access_config {}
  }

  service_account {
    email  = var.service_account_email
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

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor --batch --yes -o /etc/apt/keyrings/cloud.google.gpg
echo "deb [signed-by=/etc/apt/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list
apt-get update
apt-get install -y google-cloud-cli
gcloud auth configure-docker ${var.artifact_registry_region}-docker.pkg.dev --quiet

docker rm -f iot_microclimate_api || true
docker pull ${var.api_container_image}

docker run -d \
  --name iot_microclimate_api \
  --restart unless-stopped \
  -p 8000:8000 \
  -e DATABASE_URL='${local.api_database_url}' \
  -e IOT_API_KEY='${var.iot_api_key}' \
  -e RUN_DB_INIT='${var.run_db_init}' \
  ${var.api_container_image}
EOT
    , "\r", "")
  }
}

resource "google_compute_firewall" "api_http" {
  name    = var.firewall_name
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  source_ranges = var.source_ranges
  target_tags   = var.tags
}