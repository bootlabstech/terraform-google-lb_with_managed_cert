resource "google_project_service" "certapi" {
  project = var.project_id
  service = "certificatemanager.googleapis.com"
}
resource "google_compute_ssl_certificate" "non-prod" {
   project = var.project_id
  name        = "self-managed-non-prod-cert"
  private_key = file ("devkey.pem")
  certificate = file ("devcert.pem")
}
resource "google_compute_ssl_certificate" "prod" {
   project = var.project_id
  name        = "self-managed-prod-cert"
  private_key = file ("prodkey.pem")
  certificate = file ("prodcert.pem")
}


resource "google_compute_instance_template" "instance_template" {
  project        = var.project_id
  name_prefix    = var.instance_template_name_prefix
  machine_type   = var.machine_type
  region         = var.region
  can_ip_forward = var.can_ip_forward

  // boot disk
  disk {
    source_image = var.template_source_image
    auto_delete  = var.auto_delete
    boot         = var.boot
  }

  // networking
  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }
  scheduling {
    preemptible       = var.preemptible
    automatic_restart = var.automatic_restart
  }
  metadata = {
    gce-software-declaration = <<-EOF
    {
      "softwareRecipes": [{
        "name": "install-gce-service-proxy-agent",
        "desired_state": "INSTALLED",
        "installSteps": [{
          "scriptRun": {
            "script": "#! /bin/bash\nZONE=$(curl --silent http://metadata.google.internal/computeMetadata/v1/instance/zone -H Metadata-Flavor:Google | cut -d/ -f4 )\nexport SERVICE_PROXY_AGENT_DIRECTORY=$(mktemp -d)\nsudo gsutil cp   gs://gce-service-proxy-"$ZONE"/service-proxy-agent/releases/service-proxy-agent-0.2.tgz   "$SERVICE_PROXY_AGENT_DIRECTORY"   || sudo gsutil cp     gs://gce-service-proxy/service-proxy-agent/releases/service-proxy-agent-0.2.tgz     "$SERVICE_PROXY_AGENT_DIRECTORY"\nsudo tar -xzf "$SERVICE_PROXY_AGENT_DIRECTORY"/service-proxy-agent-0.2.tgz -C "$SERVICE_PROXY_AGENT_DIRECTORY"\n"$SERVICE_PROXY_AGENT_DIRECTORY"/service-proxy-agent/service-proxy-agent-bootstrap.sh"
          }
        }]
      }]
    }
    EOF
    enable-guest-attributes  = var.enable-guest-attributes
    enable-osconfig          = var.enable-osconfig
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "instance_group_manager" {
  project = var.project_id
  name    = var.instance_group_manager_name
  version {
    instance_template = google_compute_instance_template.instance_template.id
  }
  base_instance_name = var.base_instance_name
  zone               = var.zone
  target_size        = var.target_size
  auto_healing_policies {
    health_check      = google_compute_https_health_check.default.id
    initial_delay_sec = 30
  }

}
resource "google_compute_instance_group_named_port" "my_ports" {
  project  = var.project_id
  group = google_compute_instance_group_manager.instance_group_manager.id
  zone  = "asia-south1-c"

  name = "https"
  port = 443
}
# resource "google_compute_http_health_check" "hc" {
#   project  = var.project_id
#   name         = "authentication-health-check"
#   request_path = "/health_check"

#   timeout_sec        = 1
#   check_interval_sec = 1
# }
resource "google_compute_https_health_check" "default" {
  project               = var.project_id
  name         = "authentication-health-check"
  request_path = "/health_check"

  timeout_sec        = 1
  check_interval_sec = 1
}
resource "google_compute_autoscaler" "scale" {
  provider = google-beta
  project  = var.project_id
  name     = var.autoscaler_name
  zone     = var.zone
  target   = google_compute_instance_group_manager.instance_group_manager.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period
    cpu_utilization {
      target = 0.8

    }

  }
}
resource "google_compute_backend_service" "backend_service" {
  depends_on = [google_compute_https_health_check.default]
  project               = var.project_id
  name                  = "${var.lb_name}-backend-service"
  protocol              = var.protocol
  health_checks         = [google_compute_https_health_check.default.id]
  load_balancing_scheme = var.load_balancing_scheme
  backend {
    group = google_compute_instance_group_manager.instance_group_manager.instance_group
  }
}
resource "google_compute_global_address" "default" {
  project      = var.project_id
  name         = "${var.lb_name}-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  project               = var.project_id
  name                  = "${var.lb_name}-forwarding-rule"
  target                = google_compute_target_https_proxy.target-proxy.id
  ip_protocol           = var.ip_protocol
  load_balancing_scheme = var.load_balancing_scheme
  port_range            = var.port_range
  ip_address            = google_compute_global_address.default.address
   depends_on = [
    google_compute_target_https_proxy.target-proxy
  ]
}

resource "google_compute_target_https_proxy" "target-proxy" {
  project = var.project_id
  ssl_certificates = var.is_prod_project ? [google_compute_ssl_certificate.prod.id] : [google_compute_ssl_certificate.non-prod.id]
  name    = "${var.lb_name}-target-proxy"
  url_map = google_compute_url_map.url_map.id
  depends_on = [
    google_compute_ssl_certificate.non-prod,
    google_compute_ssl_certificate.prod,
    google_compute_url_map.url_map
  ]
  
}

resource "google_compute_url_map" "url_map" {
  project         = var.project_id
  name            = "${var.lb_name}-url-map"
  default_service = google_compute_backend_service.backend_service.id
  depends_on = [
    google_compute_backend_service.backend_service
  ]
}



