# ไฟล์นี้คือ "หน้าสั่งของ": บอกว่าอยากได้เครื่องอะไร รันบริการอะไร ใช้ image tag ไหน
# ไฟล์ที่คุณจะแก้บ่อยที่สุดตอน deploy คือไฟล์นี้ (แก้เลข tag ของ image)
# ส่วน "วิธีทำ" อยู่ที่ modules/slippass-stack

# output = ค่าที่อยากให้โชว์ตอนจบ (ที่นี่คือ IP ของ Droplet)
output "ipv4_address" {
  value = module.slippass.ipv4_address
}

# DNS: สร้าง record ใน Cloudflare ให้ชื่อเว็บชี้มาที่ IP ของ Droplet
# module "cloudflare_dns" {
#   source = "../../modules/cloudflare-dns"

#   zone_id      = var.cloudflare_zone_id
#   zone_name    = var.domain
#   ipv4_address = module.slippass.ipv4_address
#   host_headers = module.slippass.host_headers
#   proxied      = false # DNS only (ไม่ผ่านเมฆส้ม) เพื่อให้ Caddy ขอใบรับรอง HTTPS ได้ตรงๆ
# }

# module = เรียกใช้ "สูตร" จากโฟลเดอร์อื่น เหมือนเรียก function แล้วส่งค่าเข้าไป
module "slippass" {
  source = "../../modules/slippass-stack" # สูตรอยู่ที่นี่

  env = "prod"

  # ค่าเครื่อง: ใส่ตรงๆ ในโค้ด (ไม่ลับ) ต้องตรงกับเครื่องจริงใน DigitalOcean เป๊ะ
  name   = "slippass"
  region = "sgp1"
  size   = "s-2vcpu-4gb"
  image  = "ubuntu-24-04-x64"

  ssh_private_key = var.ssh_private_key              # ค่าลับ ส่งต่อไปให้ module
  registry_host   = "asia-southeast1-docker.pkg.dev" # ที่เก็บ docker image (Google)
  gcp_credentials = var.gcp_credentials

  # services = รายการบริการที่จะรันบน Droplet (ชื่อ api, web)
  services = {
    api = {
      dir = "/opt/slippass-tf/api" # โฟลเดอร์บน Droplet ที่จะวางไฟล์ compose
      # image + tag: แก้เลข v0.0.10 เป็นเวอร์ชันใหม่ แล้ว push = deploy
      image     = "asia-southeast1-docker.pkg.dev/livezer-dev/bindzertech-images/slippass-api:v0.0.10"
      hostname  = "tf-api.${var.domain}" # ชื่อเว็บของ api (Caddy รับแล้วส่งต่อ)
      port      = 3000                   # พอร์ต "ในคอนเทนเนอร์"
      host_port = 3000                   # พอร์ต "บนเครื่อง" (ใช้พอร์ตเดียวกับของจริง ต้องหยุดคอนเทนเนอร์เดิมก่อน apply)
      environment = [
        # ตัวแปรสภาพแวดล้อมที่ส่งเข้าคอนเทนเนอร์ ค่าลับมาจาก var
        { name = "SERVICE_ENV", value = var.api_service_env },
      ]
      # healthcheck = docker เช็กเองว่า api ยังปกติไหม (เรียก /ready ทุก 30 วินาที)
      healthcheck = {
        test     = ["CMD", "bun", "-e", "fetch('http://localhost:3000/ready').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
        interval = "30s"
        timeout  = "5s"
        retries  = 3
      }
    }
    web = {
      dir         = "/opt/slippass-tf/web"
      image       = "asia-southeast1-docker.pkg.dev/livezer-dev/bindzertech-images/slippass-web:v0.0.14"
      hostname    = "tf-web.${var.domain}"
      port        = 8080
      host_port   = 8081 # ใช้พอร์ตเดียวกับของจริง ต้องหยุดคอนเทนเนอร์เดิมก่อน apply
      environment = []   # web ไม่มี env (ถูกฝังตอน build image แล้ว)
      healthcheck = null # ไม่มี healthcheck
    }
  }
}
