output "api_vm_external_ip" {
  value = google_compute_instance.api_vm.network_interface[0].access_config[0].nat_ip
}

output "api_vm_self_link" {
  value = google_compute_instance.api_vm.self_link
}