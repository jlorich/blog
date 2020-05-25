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
