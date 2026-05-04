# App VM: Docker runs the same API image on port 8000.
# HTTPS traffic for API is terminated at the external load balancer.

locals {
  api_database_url = "postgresql+asyncpg://${urlencode(var.db_user)}:${urlencode(var.db_password)}@${google_compute_instance.postgres_vm.network_interface[0].network_ip}:5432/${urlencode(var.db_name)}"
}

resource "google_compute_instance" "api_vm" {
  name         = "iot-api-vm"
  machine_type = var.api_vm_machine_type
  zone         = var.zone
  tags         = ["iot-api"]

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

  # Needed to pull the API image from Artifact Registry (and to avoid "service account: false").
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

# Artifact Registry: VM service account pulls images (grant roles/artifactregistry.reader on the SA if needed).
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
  -e GRAFANA_API_KEY='${var.grafana_api_key}' \
  -e RUN_DB_INIT='${var.run_db_init}' \
  ${var.api_container_image}
EOT
    , "\r", "")
  }
}

resource "google_compute_firewall" "api_http" {
  name    = "allow-api-http"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]
  target_tags   = ["iot-api"]
}
