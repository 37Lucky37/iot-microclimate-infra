variable "vm_name" {
  description = "Name of the API VM"
  type        = string
  default     = "iot-api-vm"
}

variable "machine_type" {
  description = "Machine type for the VM"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "tags" {
  description = "Tags for the VM"
  type        = list(string)
  default     = ["iot-api"]
}

variable "disk_image" {
  description = "Boot disk image"
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 30
}

variable "disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-standard"
}

variable "vpc_id" {
  description = "VPC network ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "vpc_name" {
  description = "VPC network name"
  type        = string
}

variable "service_account_email" {
  description = "Service account email"
  type        = string
}

variable "firewall_name" {
  description = "Name of the firewall rule"
  type        = string
  default     = "allow-api-http"
}

variable "source_ranges" {
  description = "Source ranges for firewall"
  type        = list(string)
  default     = ["35.191.0.0/16", "130.211.0.0/22"]
}

variable "db_private_ip" {
  description = "Database private IP"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "artifact_registry_region" {
  description = "Artifact Registry region"
  type        = string
}

variable "api_container_image" {
  description = "API container image"
  type        = string
}

variable "iot_api_key" {
  description = "IoT API key"
  type        = string
  sensitive   = true
}

variable "grafana_api_key" {
  description = "Grafana API key"
  type        = string
  sensitive   = true
}

variable "run_db_init" {
  description = "Run DB init flag"
  type        = string
}