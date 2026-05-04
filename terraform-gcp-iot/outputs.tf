output "api_url" {
  value       = "https://${var.api_domain}"
  description = "Public HTTPS URL for the API load balancer."
}

output "grafana_url" {
  value       = "https://${var.grafana_domain}"
  description = "Public HTTPS URL for Grafana through the load balancer."
}

output "load_balancer_ip" {
  value       = module.load_balancer.load_balancer_ip
  description = "Public IP address assigned to the HTTPS load balancer."
}

output "db_private_ip" {
  value       = module.database.db_private_ip
  description = "Private IP of the TimescaleDB VM (Postgres port 5432)."
}

output "api_vm_external_ip" {
  value       = module.api.api_vm_external_ip
  description = "Ephemeral public IP of the API VM."
}

output "grafana_vm_external_ip" {
  value       = module.grafana.grafana_vm_external_ip
  description = "Ephemeral public IP of the Grafana VM."
}
