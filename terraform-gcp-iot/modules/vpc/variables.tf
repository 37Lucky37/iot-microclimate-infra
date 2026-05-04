variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "iot-vpc"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "iot-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.10.0.0/24"
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "router_name" {
  description = "Name of the router"
  type        = string
  default     = "iot-router"
}

variable "nat_name" {
  description = "Name of the NAT"
  type        = string
  default     = "iot-nat"
}

variable "ssh_firewall_name" {
  description = "Name of the SSH firewall rule"
  type        = string
  default     = "allow-ssh-iot"
}