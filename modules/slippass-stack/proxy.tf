# ไฟล์นี้คือ "ทางเข้าจากอินเทอร์เน็ต" (เทียบเท่า alb.tf ของ petio)
# ใช้ Caddy (reverse proxy) รับพอร์ต 80/443 บน Droplet แล้วส่งต่อเข้า api/web ตามชื่อเว็บ
# Caddy ขอและต่ออายุใบรับรอง HTTPS (Let's Encrypt) ให้เองอัตโนมัติ

locals {
  # เฉพาะบริการที่ตั้ง hostname ไว้เท่านั้นที่จะเปิดสู่อินเทอร์เน็ต
  public_services = { for k, svc in var.services : k => svc if svc.hostname != null }

  # Caddyfile: หนึ่งบล็อกต่อหนึ่ง hostname -> ส่งต่อไปที่พอร์ตบนเครื่อง (127.0.0.1:host_port)
  caddyfile = join("\n", [
    for k, svc in local.public_services :
    "${svc.hostname} {\n  reverse_proxy 127.0.0.1:${svc.host_port}\n}\n"
  ])

  # network_mode = host ให้ Caddy เห็น 127.0.0.1 ของเครื่องจริง (เพื่อคุยกับ api/web ที่ bind ไว้ที่นั่น)
  caddy_compose = jsonencode({
    services = {
      caddy = {
        image        = "caddy:2.8.4-alpine"
        restart      = "unless-stopped"
        network_mode = "host"
        volumes = [
          "./Caddyfile:/etc/caddy/Caddyfile:ro",
          "caddy_data:/data", # เก็บใบรับรอง HTTPS ไม่ให้หายตอนสร้างคอนเทนเนอร์ใหม่
        ]
      }
    }
    volumes = { caddy_data = {} }
  })
}

resource "terraform_data" "proxy" {
  # มี hostname อย่างน้อย 1 ตัวถึงจะติดตั้ง Caddy
  count = length(local.public_services) > 0 ? 1 : 0

  # ถ้า Caddyfile หรือ compose เปลี่ยน ให้รันใหม่
  triggers_replace = [sha256(local.caddyfile), sha256(local.caddy_compose)]

  connection {
    type        = "ssh"
    host        = digitalocean_droplet.main.ipv4_address
    user        = var.ssh_user
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p ${var.proxy_dir}"]
  }

  provisioner "file" {
    content     = local.caddyfile
    destination = "${var.proxy_dir}/Caddyfile"
  }

  provisioner "file" {
    content     = local.caddy_compose
    destination = "${var.proxy_dir}/docker-compose.yml"
  }

  # up -d = รัน/สร้างใหม่ถ้า compose เปลี่ยน, caddy reload = โหลด Caddyfile ใหม่โดยไม่ตัดการเชื่อมต่อ
  provisioner "remote-exec" {
    inline = [
      "cd ${var.proxy_dir} && docker compose up -d --remove-orphans",
      "cd ${var.proxy_dir} && docker compose exec -T caddy caddy reload --config /etc/caddy/Caddyfile",
    ]
  }

  # api/web ต้องรันก่อน Caddy ถึงจะส่งต่อได้
  depends_on = [terraform_data.service]
}

output "host_headers" {
  value       = [for k, svc in local.public_services : svc.hostname]
  description = "Public hostnames served by the proxy (used by the DNS module)"
}
