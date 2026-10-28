# ไฟล์นี้คือ "ทางเข้าจากอินเทอร์เน็ต" (เทียบเท่า alb.tf ของ petio)
# บน Droplet มี Caddy (บริการของเครื่อง ไม่ใช่ docker) รับพอร์ต 80/443 อยู่แล้ว
# เราไม่ลงตัวใหม่ แต่ให้ Terraform เขียนไฟล์ /etc/caddy/Caddyfile ของตัวเดิม แล้วสั่ง reload
# (Terraform เป็นเจ้าของไฟล์นี้ ใครแก้มือบนเครื่องจะถูกทับตอน apply)

locals {
  # ทุก hostname ของแต่ละบริการ -> ส่งต่อไปที่พอร์ตบนเครื่อง (127.0.0.1:host_port)
  service_routes = {
    for h in flatten([
      for k, svc in var.services : [
        for hostname in svc.hostnames : { host = hostname, upstream = "127.0.0.1:${svc.host_port}" }
      ]
    ]) : h.host => h.upstream
  }

  # รวมกับเว็บคงที่ที่ Terraform ไม่ได้ดูแลบริการ (เช่น slippass.co -> 3100)
  all_routes = merge(var.static_routes, local.service_routes)

  # Caddyfile: auto_https disable_redirects ตามของเดิม (เปิดได้ทั้ง http และ https ไม่บังคับ redirect)
  # แต่ละ hostname ได้บล็อก "http://ชื่อ, https://ชื่อ" ส่งต่อไป upstream
  caddyfile = join("\n", concat(
    ["{\n  auto_https disable_redirects\n}\n"],
    [
      for host, upstream in local.all_routes :
      "http://${host}, https://${host} {\n  reverse_proxy ${upstream}\n}\n"
    ]
  ))
}

resource "terraform_data" "proxy" {
  # ถ้า Caddyfile เปลี่ยน ให้รันใหม่
  triggers_replace = [sha256(local.caddyfile)]

  connection {
    type        = "ssh"
    host        = digitalocean_droplet.main.ipv4_address
    user        = var.ssh_user
    private_key = var.ssh_private_key
  }

  # 1) อัปโหลดไว้ที่ /tmp ก่อน ยังไม่แตะไฟล์จริง
  provisioner "file" {
    content     = local.caddyfile
    destination = "/tmp/slippass-Caddyfile"
  }

  # 2) ตรวจ syntax ก่อน (ถ้าผิดจะหยุด ไม่แตะของจริง) -> สำรองไฟล์เดิมไว้ครั้งแรก -> วางไฟล์ใหม่ -> reload
  provisioner "remote-exec" {
    inline = [
      "caddy validate --config /tmp/slippass-Caddyfile --adapter caddyfile",
      "cp -n /etc/caddy/Caddyfile /etc/caddy/Caddyfile.before-terraform",
      "install -m 644 /tmp/slippass-Caddyfile /etc/caddy/Caddyfile",
      "rm -f /tmp/slippass-Caddyfile",
      "systemctl reload caddy",
    ]
  }

  # api/web ต้องรันก่อน Caddy ถึงจะส่งต่อได้
  depends_on = [terraform_data.service]
}
