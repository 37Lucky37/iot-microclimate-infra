resource "google_compute_instance_group" "api" {
  name = "iot-api-instance-group"
  zone = var.zone
  instances = [
    google_compute_instance.api_vm.self_link,
  ]

  named_port {
    name = "http"
    port = 8000
  }
}

resource "google_compute_instance_group" "grafana" {
  name = "iot-grafana-instance-group"
  zone = var.zone
  instances = [
    google_compute_instance.grafana_vm.self_link,
  ]

  named_port {
    name = "grafana"
    port = 3000
  }
}

resource "google_compute_health_check" "api" {
  name = "iot-api-health-check"

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
  name = "iot-grafana-health-check"

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
  name                  = "iot-api-backend-service"
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
  name                  = "iot-grafana-backend-service"
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
  name = "iot-lb-url-map"

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

resource "google_compute_managed_ssl_certificate" "lb" {
  name = "iot-lb-ssl-cert"

  managed {
    domains = [
      var.api_domain,
      var.grafana_domain,
    ]
  }

  lifecycle {
    prevent_destroy = true
    create_before_destroy = true
  }
}

resource "google_compute_target_https_proxy" "lb" {
  name            = "iot-https-proxy"
  url_map         = google_compute_url_map.lb.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.lb.self_link]
}

resource "google_compute_global_address" "lb" {
  name = "iot-lb-ip"
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = "iot-https-forwarding-rule"
  ip_address = google_compute_global_address.lb.address
  port_range = "443"
  target     = google_compute_target_https_proxy.lb.self_link
}

resource "google_compute_url_map" "http_redirect" {
  name = "iot-http-redirect-map"

  default_url_redirect {
    https_redirect           = true
    strip_query              = false
    redirect_response_code   = "MOVED_PERMANENTLY_DEFAULT"
  }
}

resource "google_compute_target_http_proxy" "redirect" {
  name    = "iot-http-redirect-proxy"
  url_map = google_compute_url_map.http_redirect.self_link
}

resource "google_compute_global_forwarding_rule" "http" {
  name       = "iot-http-forwarding-rule"
  ip_address = google_compute_global_address.lb.address
  port_range = "80"
  target     = google_compute_target_http_proxy.redirect.self_link
}