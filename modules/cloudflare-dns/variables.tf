# ช่องรับค่าของสูตร cloudflare-dns (ค่าส่งมาจาก envs/prod/main.tf)

variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID ของโดเมน (หน้า Overview ของโดเมนใน Cloudflare)"
}

variable "zone_name" {
  type        = string
  description = "Root domain name, e.g. 'example.com'. Used to extract subdomain from host_headers."
}

variable "ipv4_address" {
  type        = string
  description = "IPv4 ของ Droplet ที่ hostname ต้องชี้ไป"
}

variable "host_headers" {
  type        = list(string)
  description = "Full hostnames (e.g. 'tf-api.example.com'). Subdomains are derived automatically."
}

# proxied = true คือเปิดเมฆส้มของ Cloudflare (ผ่าน Cloudflare ก่อนถึงเครื่อง)
variable "proxied" {
  type        = bool
  default     = true
  description = "Route traffic through Cloudflare proxy"
}
