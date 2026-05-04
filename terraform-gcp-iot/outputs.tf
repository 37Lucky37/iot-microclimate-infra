output "api_url" {
  value       = "https://${var.api_domain}"
  description = "Public HTTPS URL for the API load balancer."
}

output "grafana_url" {
  value       = "https://${var.grafana_domain}"
  description = "Public HTTPS URL for Grafana through the load balancer."
}

output "load_balancer_ip" {
  value       = google_compute_global_address.lb.address
  description = "Public IP address assigned to the HTTPS load balancer."
}

output "db_private_ip" {
  value       = google_compute_instance.postgres_vm.network_interface[0].network_ip
  description = "Private IP of the TimescaleDB VM (Postgres port 5432)."
}

output "api_vm_external_ip" {
  value       = google_compute_instance.api_vm.network_interface[0].access_config[0].nat_ip
  description = "Ephemeral public IP of the API VM."
}

output "grafana_vm_external_ip" {
  value       = google_compute_instance.grafana_vm.network_interface[0].access_config[0].nat_ip
  description = "Ephemeral public IP of the Grafana VM."
}
