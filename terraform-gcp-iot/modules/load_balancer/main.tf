resource "google_compute_instance_group" "api" {
  name = var.api_instance_group_name
  zone = var.zone
  instances = [
    var.api_vm_self_link,
  ]

  named_port {
    name = "http"
    port = 8000
  }
}

resource "google_compute_instance_group" "grafana" {
  name = var.grafana_instance_group_name
  zone = var.zone
  instances = [
    var.grafana_vm_self_link,
  ]

  named_port {
    name = "grafana"
    port = 3000
  }
}

resource "google_compute_health_check" "api" {
  name = var.api_health_check_name

  http_health_check {
    port         = 8000
    request_path = "/health"
  }

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}

resource "google_compute_health_check" "grafana" {
  name = var.grafana_health_check_name

  http_health_check {
    port         = 3000
    request_path = "/api/health"
  }

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}

resource "google_compute_backend_service" "api" {
  name                  = var.api_backend_service_name
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  enable_cdn            = false
  health_checks         = [google_compute_health_check.api.self_link]
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_instance_group.api.self_link
  }
}

resource "google_compute_backend_service" "grafana" {
  name                  = var.grafana_backend_service_name
  protocol              = "HTTP"
  port_name             = "grafana"
  timeout_sec           = 30
  enable_cdn            = false
  health_checks         = [google_compute_health_check.grafana.self_link]
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_instance_group.grafana.self_link
  }
}

resource "google_compute_url_map" "lb" {
  name = var.url_map_name

  default_service = google_compute_backend_service.api.self_link

  host_rule {
    hosts       = [var.api_domain]
    path_matcher = "api-matcher"
  }

  host_rule {
    hosts       = [var.grafana_domain]
    path_matcher = "grafana-matcher"
  }

  path_matcher {
    name            = "api-matcher"
    default_service = google_compute_backend_service.api.self_link
  }

  path_matcher {
    name            = "grafana-matcher"
    default_service = google_compute_backend_service.grafana.self_link
  }
}

# Certificate is assumed to be created separately and is permanent
data "google_compute_ssl_certificate" "lb" {
  name = var.ssl_certificate_name
}

resource "google_compute_target_https_proxy" "lb" {
  name            = var.https_proxy_name
  url_map         = google_compute_url_map.lb.self_link
  ssl_certificates = [data.google_compute_ssl_certificate.lb.self_link]
}

resource "google_compute_global_address" "lb" {
  name = var.global_address_name
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = var.https_forwarding_rule_name
  ip_address = google_compute_global_address.lb.address
  port_range = "443"
  target     = google_compute_target_https_proxy.lb.self_link
}

resource "google_compute_url_map" "http_redirect" {
  name = var.http_redirect_map_name

  default_url_redirect {
    https_redirect           = true
    strip_query              = false
    redirect_response_code   = "MOVED_PERMANENTLY_DEFAULT"
  }
}

resource "google_compute_target_http_proxy" "redirect" {
  name    = var.http_redirect_proxy_name
  url_map = google_compute_url_map.http_redirect.self_link
}

resource "google_compute_global_forwarding_rule" "http" {
  name       = var.http_forwarding_rule_name
  ip_address = google_compute_global_address.lb.address
  port_range = "80"
  target     = google_compute_target_http_proxy.redirect.self_link
}