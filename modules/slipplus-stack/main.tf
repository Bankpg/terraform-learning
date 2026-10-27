terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_droplet" "main" {
  name   = var.name
  region = var.region
  size   = var.size
  image  = var.image

  lifecycle {
    # The Droplet is imported, not created. Its image is reported in a form that
    # differs from the config, and a replacement would destroy the live server.
    ignore_changes  = [image]
    prevent_destroy = true
  }
}
