# One-time import of the existing prod Droplet. Delete this file after the first apply
# succeeds. The Droplet stays in state.
import {
  to = module.web.digitalocean_droplet.this
  id = var.droplet_id
}
