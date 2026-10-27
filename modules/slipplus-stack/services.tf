locals {
  # "$" is doubled so Compose does not interpolate it inside env values.
  compose = {
    for k, svc in var.services : k => jsonencode({
      services = {
        (k) = merge(
          {
            image   = svc.image
            restart = "unless-stopped"
            ports   = ["127.0.0.1:${svc.host_port}:${svc.port}"]
            environment = merge(
              { PORT = tostring(svc.port) },
              { for e in svc.environment : e.name => replace(e.value, "$", "$$") }
            )
            logging = {
              driver  = "json-file"
              options = { max-size = "10m", max-file = "5" }
            }
          },
          svc.healthcheck == null ? {} : { healthcheck = svc.healthcheck }
        )
      }
    })
  }
}

resource "terraform_data" "registry_login" {
  triggers_replace = [nonsensitive(sha256(var.gcp_credentials))]

  connection {
    type        = "ssh"
    host        = digitalocean_droplet.main.ipv4_address
    user        = var.ssh_user
    private_key = var.ssh_private_key
  }

  provisioner "file" {
    content     = var.gcp_credentials
    destination = "/root/.gcp-registry-key.json"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /root/.gcp-registry-key.json",
      "docker login -u _json_key --password-stdin https://${var.registry_host} < /root/.gcp-registry-key.json",
      "rm -f /root/.gcp-registry-key.json",
    ]
  }
}

resource "terraform_data" "service" {
  for_each         = var.services
  triggers_replace = [nonsensitive(sha256(local.compose[each.key]))]

  connection {
    type        = "ssh"
    host        = digitalocean_droplet.main.ipv4_address
    user        = var.ssh_user
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = ["umask 077", "mkdir -p ${each.value.dir}"]
  }

  provisioner "file" {
    content     = local.compose[each.key]
    destination = "${each.value.dir}/docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ${each.value.dir}/docker-compose.yml",
      "cd ${each.value.dir} && docker compose pull && docker compose up -d --remove-orphans --wait",
    ]
  }

  depends_on = [terraform_data.registry_login]
}

output "ipv4_address" {
  value       = digitalocean_droplet.main.ipv4_address
  description = "Public IPv4 address of the Droplet"
}
