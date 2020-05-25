variable "environment" {
  default = "dev"
}

variable "name" {
  default = "blog"
}

variable "domain" {
  default = "joeylorich.net"
}

variable "location" {
  default = "West US 2"
}

variable "cdn_location" {
  default = "West US" # CDN is not available in West US 2
}

variable "prefix" {
  default = "jlorich"
}

variable "dns_resource_group" {
  default = "dns-prod-rg" # where does DNS live for the appropriate zone.  DNS usually is managed manually.
}
