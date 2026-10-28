# สูตรนี้สร้าง DNS record ใน Cloudflare ให้ชื่อโดเมน (hostname) ชี้มาที่ IP ของ Droplet
# ทำตาม petio-git-ops แต่ใช้ A record (ชี้ IP) แทน CNAME (ชี้ชื่อ ALB) เพราะเราไม่มี ALB

terraform {
  # required_providers = บอกว่าสูตรนี้ใช้ปลั๊กอิน cloudflare
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

locals {
  # แปลง hostname เต็มเป็นชื่อ record ใน Cloudflare:
  # "tf-api.example.com" -> "tf-api"
  # "example.com"        -> "@"  (โดเมนหลัก)
  record_names = {
    for h in var.host_headers :
    h => h == var.zone_name ? "@" : trimsuffix(h, ".${var.zone_name}")
  }
}

# for_each = ทำซ้ำให้ทุก hostname ใน host_headers
resource "cloudflare_record" "a" {
  for_each = local.record_names

  zone_id = var.zone_id
  name    = each.value
  content = var.ipv4_address
  type    = "A"
  proxied = var.proxied
  ttl     = 1 # 1 = auto (Cloudflare กำหนดเอง)
}
