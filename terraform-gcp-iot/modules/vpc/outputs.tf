output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "subnet_id" {
  value = google_compute_subnetwork.subnet.id
}

output "subnet_cidr" {
  value = google_compute_subnetwork.subnet.ip_cidr_range
}

output "vpc_name" {
  value = google_compute_network.vpc.name
}