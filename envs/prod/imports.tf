# One-time import of the existing prod Droplet. Delete this file after the first apply
# succeeds. The Droplet stays in state.
import {
  to = module.slipplus.digitalocean_droplet.main
  id = var.droplet_id
}
