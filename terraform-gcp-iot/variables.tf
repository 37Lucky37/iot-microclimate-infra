variable "project_id" {
  default = "project-b12048a7-83d0-420b-ac8"
}

variable "region" {
  default = "europe-west1"
}

variable "zone" {
  default = "europe-west1-b"
}

variable "postgres_vm_machine_type" {
  default = "e2-medium"
}

variable "db_user" {
  default = "telemetry_user"
}

variable "db_password" {
  default = "StrongPassword123!"
}

variable "db_name" {
  default = "telemetry_db"
}

variable "iot_api_key" {
  default = "supersecretawskey123"
}

variable "grafana_api_key" {
  default = "supersecretgrafanakey456"
}

variable "run_db_init" {
  default = "false"
}

variable "api_vm_machine_type" {
  default = "e2-medium"
}

variable "api_container_image" {
  default = "europe-west2-docker.pkg.dev/project-b12048a7-83d0-420b-ac8/iot-repo/iot-api:v1"
}

variable "artifact_registry_region" {
  description = "Region segment in the image hostname (e.g. europe-west2-docker.pkg.dev)."
  default     = "europe-west2"
}

variable "api_domain" {
  description = "Public domain name for the API."
  default     = "microclimate-kk.uk"
}

variable "grafana_domain" {
  description = "Public domain name for Grafana."
  default     = "metrics-kk.uk"
}

variable "grafana_vm_machine_type" {
  description = "Machine type for the Grafana VM."
  default     = "e2-medium"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana."
  default     = "admin123"
}
