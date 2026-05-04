variable "vm_name" {
  description = "Name of the database VM"
  type        = string
  default     = "iot-postgres-vm"
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
  default     = ["iot-postgres"]
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

variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
}

variable "firewall_name" {
  description = "Name of the firewall rule"
  type        = string
  default     = "allow-postgres-from-vpc-subnet"
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