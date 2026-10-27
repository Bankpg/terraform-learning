variable "env" {
  type        = string
  description = "Environment name (prod)"
}

variable "name" {
  type        = string
  description = "Droplet name. Must match the existing Droplet"
}

variable "region" {
  type        = string
  description = "DigitalOcean region slug. Must match the existing Droplet"
}

variable "size" {
  type        = string
  description = "Droplet size slug. Must match the existing Droplet"
}

variable "image" {
  type        = string
  description = "Image slug. Only used at creation, ignored on the imported Droplet"
}

variable "ssh_user" {
  type        = string
  default     = "root"
  description = "SSH user Terraform uses on the Droplet"
}

variable "ssh_private_key" {
  type        = string
  sensitive   = true
  description = "Private key Terraform uses to SSH into the Droplet"
}

variable "registry_host" {
  type        = string
  description = "Docker registry host the images are pulled from"
}

variable "gcp_credentials" {
  type        = string
  sensitive   = true
  description = "GCP service account key JSON used to docker login to Artifact Registry on the Droplet"
}

variable "services" {
  type = map(object({
    dir         = string
    image       = string
    port        = number
    host_port   = number
    environment = optional(list(object({ name = string, value = string })), [])
    healthcheck = optional(object({
      test     = list(string)
      interval = string
      timeout  = string
      retries  = number
    }))
  }))
  description = "Map of compose services to deploy on the Droplet"
}
