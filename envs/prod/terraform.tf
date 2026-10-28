# ไฟล์นี้ตั้งค่า "พื้นฐาน" ของ Terraform: ใครเป็นคนรัน, เก็บสถานะที่ไหน, ใช้ปลั๊กอินอะไร

terraform {
  # cloud = ให้ HCP Terraform (เว็บ app.terraform.io) เป็นคนรัน plan/apply
  # และเก็บ "state" (สมุดจดว่า Terraform เคยดูแลอะไรไว้) ให้
  cloud {
    organization = "PonsagonPlayGround"
    workspaces {
      # ชื่อนี้ต้องตรงกับ workspace ที่สร้างใน HCP เป๊ะ ถ้าไม่ตรงจะ init ไม่ผ่าน
      name = "terraform-learning"
    }
  }

  # provider = ปลั๊กอินที่ทำให้ Terraform คุยกับบริการภายนอกได้ (ที่นี่คือ DigitalOcean)
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0" # ใช้เวอร์ชัน 2.x ล่าสุด แต่ไม่ขึ้น 3.0 เอง
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.5" # เวอร์ชัน Terraform ต่ำสุดที่ใช้ได้
}

provider "digitalocean" {
  # Token is read from DIGITALOCEAN_TOKEN env var set in HCP Terraform
  # (ไม่ต้องเขียน token ในโค้ด ไปตั้งเป็น Environment variable ใน HCP แทน)
}

provider "cloudflare" {
  # Token is read from CLOUDFLARE_API_TOKEN env var set in HCP Terraform (Sensitive)
}
