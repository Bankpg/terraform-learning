variable "droplet_id" {
  type        = string
  description = "ID of the existing prod Droplet, used by the one-time import in imports.tf"
}

variable "droplet_name" {
  type = string
}

variable "droplet_region" {
  type = string
}

variable "droplet_size" {
  type = string
}

variable "droplet_image" {
  type = string
}

variable "ssh_private_key" {
  type      = string
  sensitive = true
}

variable "gcp_credentials" {
  type      = string
  sensitive = true
}

# API service
variable "api_service_env" {
  type      = string
  sensitive = true
}
