# ไฟล์นี้ประกาศ "ช่องรับค่า" ของสูตร เหมือนพารามิเตอร์ของ function
# ค่าถูกส่งมาจาก envs/prod/main.tf ตรงบล็อก module "slippass"

variable "env" {
  type        = string
  description = "Environment name (prod)"
}

variable "name" {
  type        = string
  description = "Droplet name. Must match the existing Droplet"
}

variable "region" {
  type        = string
  description = "DigitalOcean region slug. Must match the existing Droplet"
}

variable "size" {
  type        = string
  description = "Droplet size slug. Must match the existing Droplet"
}

variable "image" {
  type        = string
  description = "Image slug. Only used at creation, ignored on the imported Droplet"
}

# ถ้าไม่ส่งค่ามา ใช้ค่า default คือ "root"
variable "ssh_user" {
  type        = string
  default     = "root"
  description = "SSH user Terraform uses on the Droplet"
}

variable "ssh_private_key" {
  type        = string
  sensitive   = true
  description = "Private key Terraform uses to SSH into the Droplet"
}

variable "registry_host" {
  type        = string
  description = "Docker registry host the images are pulled from"
}

variable "gcp_credentials" {
  type        = string
  sensitive   = true
  description = "GCP service account key JSON used to docker login to Artifact Registry on the Droplet"
}

# services = map (ชื่อ -> รายละเอียด) ของบริการที่จะรัน เช่น api, web
# แต่ละบริการต้องมี dir, image, port, host_port ส่วน environment กับ healthcheck ใส่หรือไม่ใส่ก็ได้ (optional)
variable "services" {
  type = map(object({
    dir         = string
    image       = string
    port        = number
    host_port   = number
    hostname    = optional(string) # ชื่อเว็บที่ให้ Caddy รับ (ถ้าไม่ใส่ = ไม่เปิดสู่อินเทอร์เน็ต)
    environment = optional(list(object({ name = string, value = string })), [])
    healthcheck = optional(object({
      test     = list(string)
      interval = string
      timeout  = string
      retries  = number
    }))
  }))
  description = "Map of compose services to deploy on the Droplet"
}

variable "proxy_dir" {
  type        = string
  default     = "/opt/slippass-tf/proxy"
  description = "Folder on the Droplet for the Caddy compose file and Caddyfile"
}
