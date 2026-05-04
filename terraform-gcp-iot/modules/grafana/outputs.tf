output "grafana_vm_external_ip" {
  value = google_compute_instance.grafana_vm.network_interface[0].access_config[0].nat_ip
}

output "grafana_vm_self_link" {
  value = google_compute_instance.grafana_vm.self_link
}