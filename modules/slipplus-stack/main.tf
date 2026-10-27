# module นี้คือ "สูตร" ที่ envs/prod/main.tf เรียกใช้
# main.tf นี้นิยามตัว Droplet, ส่วน services.tf นิยามการ deploy docker ลงบน Droplet

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# resource "ชนิด" "ชื่อ" = ของที่ Terraform ดูแล ที่นี่คือ Droplet ชื่อภายใน Terraform ว่า "main"
# (ที่อ้างถึงใน imports.tf ว่า module.slipplus.digitalocean_droplet.main)
resource "digitalocean_droplet" "main" {
  name   = var.name   # ต้องตรงกับชื่อจริง ถ้าไม่ตรง Terraform จะอยากสร้างเครื่องใหม่
  region = var.region # ต้องตรงกับของจริง (แก้ภายหลังไม่ได้ ต้องสร้างใหม่)
  size   = var.size
  image  = var.image

  lifecycle {
    # The Droplet is imported, not created. Its image is reported in a form that
    # differs from the config, and a replacement would destroy the live server.
    # ignore_changes = ไม่ต้องสนใจถ้าช่องเหล่านี้ต่างกัน
    # Droplet จริงสร้างจากหน้า console จึงมีค่าที่โค้ดเราไม่ได้เขียน (เช่น เปิด monitoring,
    # droplet_agent) ถ้าไม่ ignore Terraform จะเห็นว่า "ไม่ตรงกับโค้ด" และบางช่องแก้ในที่เดิมไม่ได้
    # จึงสรุปว่าต้อง replace (ลบแล้วสร้างใหม่) ซึ่งอันตรายกับเครื่อง prod
    ignore_changes = [
      image,
      monitoring,
      droplet_agent,
      ipv6,
      backups,
      tags,
      user_data,
      ssh_keys,
      vpc_uuid,
    ]
    # prevent_destroy = ห้ามลบเด็ดขาด ถ้า plan ต้องลบเครื่องนี้ จะ error ทันที
    # (ตัวนี้แหละที่กันไม่ให้เซิร์ฟเวอร์จริงถูกลบตอน plan ขึ้นว่า replace)
    prevent_destroy = true
  }
}
