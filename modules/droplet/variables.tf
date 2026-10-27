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
  description = "Image slug. Not applied to the imported Droplet (see main.tf)"
}
