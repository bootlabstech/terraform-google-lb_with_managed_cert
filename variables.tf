variable "project_id" {
  description = "the ID of the project where the resources will be created"
  type        = string
}
#forwarding_rule
variable "ip_protocol" {
  type        = string
  description = "The IP protocol to which this rule applies.  Possible values are TCP, UDP, ESP, AH, SCTP, and ICMP."
}
variable "load_balancing_scheme" {
  type        = string
  description = "This signifies what the GlobalForwardingRule will be used.The value of INTERNAL_SELF_MANAGED means that this will be used for Internal Global HTTP(S) LB. The value of EXTERNAL means that this will be used for External Global Load Balancing (HTTP(S) LB, External TCP/UDP LB, SSL Proxy). The value of EXTERNAL_MANAGED means that this will be used for Global external HTTP(S) load balancers.  Possible values are EXTERNAL, EXTERNAL_MANAGED, and INTERNAL_SELF_MANAGED"
}
variable "port_range" {
  type        = string
  description = "This field is used along with the target field https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule#port_range"
}
variable "is_prod_project" {
  type        = bool
  description = "whether the project is prod or non-prod"
}
# variable "ssl_certificates" {
#   type        = list(string)
#   description = "The certificate to be used by the load balancer"
# }
# variable "ip_address" {
#   type        = string
#   description = "The IP address that this forwarding rule serves. When a client sends traffic to this IP address, the forwarding rule directs the traffic to the target that you specify in the forwarding rule"
# }
# variable "non_prod_pem_certificate" {
#   type        = string
#   description = "cert value"
#   sensitive   = true
#   # default     = file("/devcert.pem")
# }
# variable "non_prod_pem_private_key" {
#   type        = string
#   description = "cert value"
#   sensitive   = true
#   # default     = file("/devkey.pem")
# }
# variable "prod_pem_certificate" {
#   type        = string
#   description = "cert value"
#   sensitive   = true
#   # default     = ("/prodcert.pem")
# }
# variable "prod_pem_private_key" {
#   type        = string
#   description = "cert value"
#   sensitive   = true
#   # default     = ("/prodkey.pem")
# }

variable "lb_name" {
  type        = string
  description = "Name of the resource; provided by the client when the resource is created"
}
#backend service
variable "protocol" {
  type        = string
  description = "The protocol this BackendService uses to communicate with backends.Possible values are HTTP, HTTPS, HTTP2, TCP, SSL, and GRPC"
}
variable "network" {
  type        = string
  description = "Network for  load balancer."
}
variable "region" {
  description = "The region the instance will sit in"
  type        = string
}
variable "instance_template_name_prefix" {
  description = "prfix for the instance template"
  type        = string
}
variable "machine_type" {
  description = "machine type of the instances"
  type        = string
}

variable "can_ip_forward" {
  description = "ip-forward configuration of the template"
  type        = bool
  default     = false
}
variable "auto_delete" {
  description = "auto-delete configuration of the template-disk"
  type        = bool
  default     = true
}
variable "boot" {
  description = "boot configuration of the template-disk"
  type        = bool
  default     = true
}
# variable "network" {
#   description = "network for the instance template"
#   type        = string
# }
variable "subnetwork" {
  description = "sub-network for the instance template"
  type        = string
}
variable "preemptible" {
  description = "Name of the disk"
  type        = bool
}
variable "automatic_restart" {
  description = "Name of the disk"
  type        = bool
  default     = true
}
variable "enable-guest-attributes" {
  description = "enable-guest-attributes config"
  type        = bool
  default     = true
}
variable "enable-osconfig" {
  description = "enable-osconfig"
  type        = bool
  default     = true
}
variable "instance_group_manager_name" {
  description = "instance_group_manager_name"
  type        = string
}
variable "base_instance_name" {
  description = "base_instance_name"
  type        = string
}
variable "zone" {
  description = "Zone of the MIG"
  type        = string
}
variable "target_size" {
  description = "Target size of the MIG"
  type        = string
}
variable "template_source_image" {
  description = "Source image self_link for the instance template"
  type        = string
}
variable "autoscaler_name" {
  description = "Name for the autoscaler"
  type        = string
}
variable "max_replicas" {
  description = "Maximum number of replicas for the autoscaler"
  type        = number
}
variable "min_replicas" {
  description = "Minimum number of replicas for the autoscaler"
  type        = number
}
variable "cooldown_period" {
  description = "The cooldown period for the autoscaler"
  type        = number
}
# variable "metric_name" {
#   description = "The metric name for the autoscaler"
#   type        = string
# }
# variable "metric_filter" {
#   description = "The metric filter for the autoscaler"
#   type        = string
# }
# variable "single_instance_assignment" {
#   description = "single_instance_assignment for the autoscaler"
#   type        = number
# }