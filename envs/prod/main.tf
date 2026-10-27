# One-time import of the existing prod Droplet. Remove this block after the first
# apply succeeds; the Droplet stays in state.
import {
  to = module.web.digitalocean_droplet.this
  id = var.droplet_id
}

module "web" {
  source = "../../modules/droplet"

  name   = var.name
  region = var.region
  size   = var.size
  image  = var.image
}

output "ipv4_address" {
  value = module.web.ipv4_address
}
