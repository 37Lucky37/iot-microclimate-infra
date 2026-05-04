# IoT Microclimate Infrastructure

This Terraform configuration deploys an IoT microclimate infrastructure on Google Cloud Platform.

## Architecture

The infrastructure consists of:

- **VPC and Networking**: Custom VPC with subnet, NAT router, and firewalls.
- **Database**: TimescaleDB (PostgreSQL) VM for time-series data.
- **API**: VM running the IoT API in Docker.
- **Grafana**: VM running Grafana for visualization.
- **Load Balancer**: HTTPS load balancer with SSL termination and HTTP redirect.

## Modules

The configuration is organized into modules:

- `modules/vpc`: Networking components
- `modules/database`: PostgreSQL VM
- `modules/api`: API VM
- `modules/grafana`: Grafana VM
- `modules/load_balancer`: Load balancer and SSL proxy
- `modules/iam`: IAM roles and service accounts

## SSL Certificates

SSL certificates are **not managed by Terraform** to make them permanent and avoid waiting during infrastructure deployment/destruction.

### To create certificates manually:

1. Create the certificate using GCP Console or gcloud:
   ```bash
   gcloud compute ssl-certificates create iot-lb-ssl-cert \
     --domains=microclimate-kk.uk,grafana-kk.uk \
     --global
   ```

2. Wait for the certificate to be active (can take up to 30 minutes).

3. Apply the Terraform configuration:
   ```bash
   terraform apply
   ```

### To destroy infrastructure without affecting certificates:

```bash
terraform destroy
```

The certificates will remain and can be reused for future deployments.

**Note:** If you have existing certificates from previous deployments, they will be automatically referenced by the data source.

## Database

The database VM runs TimescaleDB (PostgreSQL) in Docker with automated migrations:

- **Database**: TimescaleDB for time-series data
- **User**: `telemetry_user` with full access to `telemetry_db`
- **Auto-migration**: Creates `telemetry` table on startup with proper indexes
- **TimescaleDB**: Automatically converts the table to a hypertable for time-series optimization

### Telemetry Table Schema

```sql
CREATE TABLE IF NOT EXISTS telemetry (
    id SERIAL PRIMARY KEY,
    device_id TEXT NOT NULL,
    temperature DOUBLE PRECISION,
    humidity DOUBLE PRECISION,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_telemetry_device_id ON telemetry(device_id);
CREATE INDEX IF NOT EXISTS idx_telemetry_timestamp ON telemetry(timestamp);

-- Hypertable conversion (TimescaleDB)
SELECT create_hypertable('telemetry', 'timestamp', if_not_exists => TRUE);

## Variables

See `variables.tf` for all configurable variables.

## Outputs

- `api_url`: HTTPS URL for the API
- `grafana_url`: HTTPS URL for Grafana
- `load_balancer_ip`: Public IP of the load balancer
- `db_private_ip`: Private IP of the database VM
- `api_vm_external_ip`: Public IP of the API VM
- `grafana_vm_external_ip`: Public IP of the Grafana VM