locals {
  grafana_database_url = "postgres://${urlencode(var.db_user)}:${urlencode(var.db_password)}@${var.db_private_ip}:5432/${urlencode(var.db_name)}"
}

resource "google_compute_instance" "grafana_vm" {
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

# Grafana directories
mkdir -p /opt/grafana-data
mkdir -p /opt/grafana-provisioning/datasources

chown -R 472:472 /opt/grafana-data
chmod -R 775 /opt/grafana-data

# PostgreSQL datasource provisioning
cat > /opt/grafana-provisioning/datasources/postgres.yaml <<EOF
apiVersion: 1

datasources:
  - name: PostgreSQL
    type: postgres
    access: proxy
    url: ${var.db_private_ip}:5432
    database: ${var.db_name}
    user: ${var.db_user}

    secureJsonData:
      password: ${var.db_password}

    jsonData:
      sslmode: disable
      postgresVersion: 1500
      timescaledb: true

    isDefault: true
    editable: true
EOF

docker rm -f iot_microclimate_grafana || true
docker pull grafana/grafana:latest

docker run -d \
  --name iot_microclimate_grafana \
  --restart unless-stopped \
  -p 3000:3000 \
  -v /opt/grafana-data:/var/lib/grafana \
  -v /opt/grafana-provisioning/datasources:/etc/grafana/provisioning/datasources \
  -e GF_SECURITY_ADMIN_PASSWORD='${var.grafana_admin_password}' \
  -e GF_USERS_ALLOW_SIGN_UP=false \
  \
  -e GF_SMTP_ENABLED=true \
  -e GF_SMTP_HOST='smtp.gmail.com:587' \
  -e GF_SMTP_USER='${var.smtp_user}' \
  -e GF_SMTP_PASSWORD='${var.smtp_password}' \
  -e GF_SMTP_FROM_ADDRESS='${var.smtp_user}' \
  -e GF_SMTP_FROM_NAME='IoT Microclimate Alerts' \
  -e GF_SMTP_SKIP_VERIFY=true \
  \
  grafana/grafana:latest

echo "Waiting for Grafana..."
sleep 15

curl http://localhost:3000/api/health || true

echo "Grafana setup completed!"
EOT
  , "\r", "")
}
}

resource "google_compute_firewall" "grafana_http" {
  name    = var.firewall_name
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = var.source_ranges
  target_tags   = var.tags
}