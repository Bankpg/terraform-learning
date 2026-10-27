resource "digitalocean_droplet" "this" {
  name   = var.name
  region = var.region
  size   = var.size
  image  = var.image

  lifecycle {
    # The Droplet is imported, not created. Its image is reported in a form that
    # differs from the config, and a replacement would destroy the live server.
    # To replace it on purpose, remove prevent_destroy first.
    ignore_changes  = [image]
    prevent_destroy = true
  }
}
