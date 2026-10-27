output "ipv4_address" {
  value = module.slipplus.ipv4_address
}

module "slipplus" {
  source = "../../modules/slipplus-stack"

  env             = "prod"
  name            = var.droplet_name
  region          = var.droplet_region
  size            = var.droplet_size
  image           = var.droplet_image
  ssh_private_key = var.ssh_private_key
  registry_host   = "asia-southeast1-docker.pkg.dev"
  gcp_credentials = var.gcp_credentials
  services = {
    api = {
      dir       = "/opt/slipplus-tf/api"
      image     = "asia-southeast1-docker.pkg.dev/livezer-dev/bindzertech-images/slippass-api:v0.0.10"
      port      = 3000
      host_port = 13000
      environment = [
        { name = "SERVICE_ENV", value = var.api_service_env },
      ]
      healthcheck = {
        test     = ["CMD", "bun", "-e", "fetch('http://localhost:3000/ready').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
        interval = "30s"
        timeout  = "5s"
        retries  = 3
      }
    }
    web = {
      dir         = "/opt/slipplus-tf/web"
      image       = "asia-southeast1-docker.pkg.dev/livezer-dev/bindzertech-images/slippass-web:v0.0.14"
      port        = 8080
      host_port   = 18081
      environment = []
      healthcheck = null
    }
  }
}
