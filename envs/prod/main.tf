module "web" {
  source = "../../modules/droplet"

  name   = var.name
  region = var.region
  size   = var.size
  image  = var.image
}
