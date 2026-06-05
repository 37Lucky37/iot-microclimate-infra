variable "project_id" {
  type = string
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
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type = string
}

variable "iot_api_key" {
  type      = string
  sensitive = true
}

variable "run_db_init" {
  default = "true"
}

variable "api_vm_machine_type" {
  default = "e2-medium"
}

variable "api_container_image" {
  type = string
}

variable "artifact_registry_region" {
  description = "Region segment in the image hostname (e.g. europe-west2-docker.pkg.dev)."
  default     = "europe-west2"
}

variable "api_domain" {
  description = "Public domain name for the API."
  type = string
}

variable "grafana_domain" {
  description = "Public domain name for Grafana."
  type = string
}

variable "grafana_vm_machine_type" {
  description = "Machine type for the Grafana VM."
  default     = "e2-medium"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana."
  type      = string
  sensitive = true
}

variable "smtp_user" {
  type = string
}

variable "smtp_password" {
  type      = string
  sensitive = true
}