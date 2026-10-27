# ไฟล์นี้คือ "หน้าสั่งของ": บอกว่าอยากได้เครื่องอะไร รันบริการอะไร ใช้ image tag ไหน
# ไฟล์ที่คุณจะแก้บ่อยที่สุดตอน deploy คือไฟล์นี้ (แก้เลข tag ของ image)
# ส่วน "วิธีทำ" อยู่ที่ modules/slipplus-stack

# output = ค่าที่อยากให้โชว์ตอนจบ (ที่นี่คือ IP ของ Droplet)
output "ipv4_address" {
  value = module.slipplus.ipv4_address
}

# module = เรียกใช้ "สูตร" จากโฟลเดอร์อื่น เหมือนเรียก function แล้วส่งค่าเข้าไป
module "slipplus" {
  source = "../../modules/slipplus-stack" # สูตรอยู่ที่นี่

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
      dir = "/opt/slipplus-tf/api" # โฟลเดอร์บน Droplet ที่จะวางไฟล์ compose
      # image + tag: แก้เลข v0.0.10 เป็นเวอร์ชันใหม่ แล้ว push = deploy
      image     = "asia-southeast1-docker.pkg.dev/livezer-dev/bindzertech-images/slippass-api:v0.0.10"
      port      = 3000  # พอร์ต "ในคอนเทนเนอร์"
      host_port = 13000 # พอร์ต "บนเครื่อง" (ตั้งต่างจากของจริงที่ใช้ 3000 จะได้ไม่ชน)
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
      dir         = "/opt/slipplus-tf/web"
      image       = "asia-southeast1-docker.pkg.dev/livezer-dev/bindzertech-images/slippass-web:v0.0.14"
      port        = 8080
      host_port   = 18081 # ของจริงใช้ 8081 จึงเลี่ยงไปใช้ 18081
      environment = []    # web ไม่มี env (ถูกฝังตอน build image แล้ว)
      healthcheck = null  # ไม่มี healthcheck
    }
  }
}
