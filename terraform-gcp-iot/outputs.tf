output "api_url" {
  value       = "http://${google_compute_instance.api_vm.network_interface[0].access_config[0].nat_ip}:8000"
  description = "Public HTTP URL for the API (ephemeral IP; use Cloud DNS / static IP for production)."
}

output "grafana_url" {
  value       = "http://${google_compute_instance.grafana_vm.network_interface[0].access_config[0].nat_ip}:3000"
  description = "Public HTTP URL for Grafana."
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
