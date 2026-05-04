variable "api_instance_group_name" {
  description = "Name of the API instance group"
  type        = string
  default     = "iot-api-instance-group"
}

variable "grafana_instance_group_name" {
  description = "Name of the Grafana instance group"
  type        = string
  default     = "iot-grafana-instance-group"
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "api_vm_self_link" {
  description = "Self link of the API VM"
  type        = string
}

variable "grafana_vm_self_link" {
  description = "Self link of the Grafana VM"
  type        = string
}

variable "api_health_check_name" {
  description = "Name of the API health check"
  type        = string
  default     = "iot-api-health-check"
}

variable "grafana_health_check_name" {
  description = "Name of the Grafana health check"
  type        = string
  default     = "iot-grafana-health-check"
}

variable "api_backend_service_name" {
  description = "Name of the API backend service"
  type        = string
  default     = "iot-api-backend-service"
}

variable "grafana_backend_service_name" {
  description = "Name of the Grafana backend service"
  type        = string
  default     = "iot-grafana-backend-service"
}

variable "url_map_name" {
  description = "Name of the URL map"
  type        = string
  default     = "iot-lb-url-map"
}

variable "api_domain" {
  description = "API domain"
  type        = string
}

variable "grafana_domain" {
  description = "Grafana domain"
  type        = string
}

variable "ssl_certificate_name" {
  description = "Name of the SSL certificate"
  type        = string
  default     = "iot-lb-ssl-cert"
}

variable "https_proxy_name" {
  description = "Name of the HTTPS proxy"
  type        = string
  default     = "iot-https-proxy"
}

variable "global_address_name" {
  description = "Name of the global address"
  type        = string
  default     = "iot-lb-ip"
}

variable "https_forwarding_rule_name" {
  description = "Name of the HTTPS forwarding rule"
  type        = string
  default     = "iot-https-forwarding-rule"
}

variable "http_redirect_map_name" {
  description = "Name of the HTTP redirect map"
  type        = string
  default     = "iot-http-redirect-map"
}

variable "http_redirect_proxy_name" {
  description = "Name of the HTTP redirect proxy"
  type        = string
  default     = "iot-http-redirect-proxy"
}

variable "http_forwarding_rule_name" {
  description = "Name of the HTTP forwarding rule"
  type        = string
  default     = "iot-http-forwarding-rule"
}