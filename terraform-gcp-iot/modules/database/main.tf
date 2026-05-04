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
apt-get install -y docker.io curl gnupg ca-certificates postgresql-client
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

echo "Waiting for database to be ready..."
for i in {1..30}; do
  if docker exec iot_microclimate_db psql -U '${var.db_user}' -d '${var.db_name}' -h localhost -c "SELECT 1" >/dev/null 2>&1; then
    echo "Database is ready!"
    break
  fi
  echo "Waiting... attempt $i/30"
  sleep 10
done

# Run database migrations
echo "Running database migrations..."
docker exec iot_microclimate_db psql -U '${var.db_user}' -d '${var.db_name}' -h localhost << 'EOF'
CREATE TABLE IF NOT EXISTS telemetry (
    id SERIAL PRIMARY KEY,
    device_id TEXT NOT NULL,
    temperature DOUBLE PRECISION,
    humidity DOUBLE PRECISION,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_telemetry_device_id ON telemetry(device_id);
CREATE INDEX IF NOT EXISTS idx_telemetry_timestamp ON telemetry(timestamp);

-- Convert to hypertable if TimescaleDB is available
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'timescaledb') THEN
        PERFORM create_hypertable('telemetry', 'timestamp', if_not_exists => TRUE);
    END IF;
END
$$;
EOF

echo "Database migration completed!"
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