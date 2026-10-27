# ไฟล์นี้ประกาศ "ช่องรับค่า" (variable) ที่ main.tf ใช้
# ประกาศแค่ว่ามีช่องอะไร ชนิดอะไร ส่วน "ค่าจริง" ไปกรอกที่ HCP -> workspace -> Variables
# เหตุที่ไม่เขียนค่าจริงในไฟล์: ไฟล์นี้ขึ้น git ใครเปิด repo ก็เห็น

# (ค่าของ Droplet ไม่ใช่ variable แล้ว ใส่ตรงใน main.tf และ imports.tf)

# ---- ค่าลับ: sensitive = true แปลว่า Terraform จะซ่อนค่าไม่ให้โชว์ในล็อก ----
variable "ssh_private_key" {
  type      = string
  sensitive = true # private key ที่ Terraform ใช้ SSH เข้า Droplet
}

variable "gcp_credentials" {
  type      = string
  sensitive = true # JSON key ของ Google service account ใช้ docker login ดึง image
}

# API service
variable "api_service_env" {
  type      = string
  sensitive = true # JSON ของ SERVICE_ENV ที่ api ใช้ (มี DB password ฯลฯ)
}
