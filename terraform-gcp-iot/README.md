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
- `modules/database`: PostgreSQL VM with automated migrations
- `modules/api`: API VM with Docker
- `modules/grafana`: Grafana VM with PostgreSQL data source pre-configured
- `modules/load_balancer`: Load balancer and SSL proxy
- `modules/iam`: IAM roles and service accounts
- `modules/grafana_alerts`: Grafana alert rules and notification configuration

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
```

## Grafana

Grafana is automatically configured on startup:

- **Access**: HTTPS at `https://metrics-kk.uk` (through load balancer)
- **Default user**: `admin`
- **Password**: Configured via `grafana_admin_password` variable
- **Data Source**: PostgreSQL is pre-configured as default data source
- **Database**: `telemetry_db` on `telemetry_user`

The PostgreSQL connection is automatically provisioned in `/opt/grafana-provisioning/datasources/postgres.yaml`.

### Access Grafana

```bash
# Get Grafana external IP
terraform output grafana_vm_external_ip

# Access at https://metrics-kk.uk (after DNS configuration)
# Or via direct IP: https://<grafana_external_ip>:3000
```

## Monitoring and Alerts

Grafana is configured with built-in alert rules that monitor your IoT telemetry data:

### Alert Types

1. **🌡️ High Temperature** (default: >35°C)
   - Triggered when temperature exceeds threshold
   - Alert sent to configured email

2. **❄️ Low Temperature** (default: <5°C)
   - Triggered when temperature falls below threshold
   - Alert sent to configured email

3. **💧 High Humidity** (default: >80%)
   - Triggered when humidity exceeds threshold
   - Alert sent to configured email

4. **🏜️ Low Humidity** (default: <20%)
   - Triggered when humidity falls below threshold
   - Alert sent to configured email

5. **📡 Device Disconnected** (default: 10 minutes offline)
   - Triggered when no telemetry data is received
   - Alert sent to configured email

### Alert Configuration

Configure alerts by setting these Terraform variables:

```terraform
alert_email             = "your-email@example.com"
temperature_high        = 35.0
temperature_low         = 5.0
humidity_high           = 80.0
humidity_low            = 20.0
device_offline_duration = 10  # minutes
```

### Creating Alert Rules in Grafana

After Grafana is deployed, you can create alert rules through the Grafana UI:

1. Go to **Alerts** → **Alert rules** in Grafana
2. Create new alert rules with conditions based on the `telemetry` table
3. Configure notification channels pointing to your email
4. Example query for high temperature alert:
   ```sql
   SELECT temperature FROM telemetry 
   WHERE timestamp > now() - interval '5 minutes'
   ORDER BY timestamp DESC LIMIT 1
   ```

### Data Ingestion

IoT devices send telemetry data directly to PostgreSQL via API:

```bash
# Example: Send telemetry data via API
curl -X POST https://api.microclimate-kk.uk/api/telemetry \
  -H "Content-Type: application/json" \
  -H "X-API-Key: supersecretawskey123" \
  -d '{
    "device_id": "device-01",
    "temperature": 22.5,
    "humidity": 65.0
  }'
```

The data is automatically stored in the `telemetry` table and available for Grafana queries.