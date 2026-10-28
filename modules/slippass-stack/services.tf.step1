# ไฟล์นี้คือส่วน deploy: SSH เข้า Droplet แล้ววางไฟล์ docker-compose และสั่งรัน
# ลำดับตอน apply: registry_login (login ที่เก็บ image) -> service api/web (วาง compose + รัน)

# locals = ตัวแปรภายใน ใช้ประกอบค่า (ไม่ใช่ช่องรับค่าจากข้างนอก)
locals {
  # วนทีละบริการใน var.services (k = ชื่อ เช่น "api", svc = รายละเอียด)
  # แล้วสร้างข้อความ docker-compose.yml (เป็น JSON ซึ่ง docker compose อ่านได้)
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

# terraform_data = resource เปล่าๆ ใช้เป็นที่ผูกคำสั่ง (provisioner) ให้รันตอน apply
# registry_login: ทำให้ Droplet ล็อกอินเข้า Google Artifact Registry เพื่อดึง image ได้
resource "terraform_data" "registry_login" {
  # รันใหม่เฉพาะตอน key เปลี่ยน (เทียบด้วย hash)
  triggers_replace = [nonsensitive(sha256(var.gcp_credentials))]

  # connection = วิธีเชื่อมต่อเข้าเครื่อง (SSH ไปที่ IP ของ Droplet ด้วย key ที่ให้)
  connection {
    type        = "ssh"
    host        = digitalocean_droplet.main.ipv4_address
    user        = var.ssh_user
    private_key = var.ssh_private_key
  }

  # provisioner "file" = อัปโหลดไฟล์ไปวางบนเครื่อง
  provisioner "file" {
    content     = var.gcp_credentials
    destination = "/root/.gcp-registry-key.json"
  }

  # provisioner "remote-exec" = สั่งคำสั่ง shell บนเครื่อง (ทีละบรรทัดใน inline)
  # ที่นี่: จำกัดสิทธิ์ไฟล์ key, docker login, แล้วลบไฟล์ key ทิ้ง
  provisioner "remote-exec" {
    inline = [
      "chmod 600 /root/.gcp-registry-key.json",
      "docker login -u _json_key --password-stdin https://${var.registry_host} < /root/.gcp-registry-key.json",
      "rm -f /root/.gcp-registry-key.json",
    ]
  }
}

# service: ทำซ้ำให้ทุกบริการ (api และ web) ด้วย for_each
# each.key = ชื่อบริการ, each.value = รายละเอียดของบริการนั้น
resource "terraform_data" "service" {
  for_each = var.services
  # triggers_replace = "ถ้าเนื้อ compose เปลี่ยน (เช่นแก้ tag) ให้รันใหม่" นี่คือหัวใจของ GitOps
  triggers_replace = [nonsensitive(sha256(local.compose[each.key]))]

  connection {
    type        = "ssh"
    host        = digitalocean_droplet.main.ipv4_address
    user        = var.ssh_user
    private_key = var.ssh_private_key
  }

  # 1) สร้างโฟลเดอร์ของบริการบน Droplet
  provisioner "remote-exec" {
    inline = ["umask 077", "mkdir -p ${each.value.dir}"]
  }

  # 2) วางไฟล์ docker-compose.yml ที่ประกอบไว้ใน locals ข้างบน
  provisioner "file" {
    content     = local.compose[each.key]
    destination = "${each.value.dir}/docker-compose.yml"
  }

  # 3) ดึง image ใหม่ แล้วรันคอนเทนเนอร์ (--wait = รอจน healthcheck ผ่าน)
  provisioner "remote-exec" {
    inline = [
      "chmod 600 ${each.value.dir}/docker-compose.yml",
      "cd ${each.value.dir} && docker compose pull && docker compose up -d --remove-orphans --wait",
    ]
  }

  # ต้อง login registry ให้เสร็จก่อน ถึงจะดึง image ได้
  depends_on = [terraform_data.registry_login]
}
