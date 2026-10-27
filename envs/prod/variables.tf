variable "droplet_id" {
  type        = string
  description = "ID of the existing prod Droplet, used by the one-time import in imports.tf"
}

variable "name" {
  type        = string
  description = "Droplet name. Must match the existing prod Droplet"
}

variable "region" {
  type        = string
  description = "DigitalOcean region slug. Must match the existing prod Droplet"
}

variable "size" {
  type        = string
  description = "Droplet size slug. Must match the existing prod Droplet"
}

variable "image" {
  type        = string
  description = "Image slug. Not applied to the imported Droplet (see modules/droplet/main.tf)"
}
