# One-time import of the existing prod Droplet. Delete this file after the first apply
# succeeds. The Droplet stays in state.
#
# อธิบาย: ปกติถ้าในโค้ดมี resource "digitalocean_droplet" Terraform จะ "สร้างใหม่"
# แต่เรามี Droplet จริงอยู่แล้ว บล็อกนี้บอกว่า "อย่าสร้าง ตัวที่ id นี้คือ resource นี้
# ให้รับไปดูแลต่อ" ใช้แค่ครั้งแรก พอ apply สำเร็จแล้วลบไฟล์นี้ทิ้งได้
import {
  to = module.slippass.digitalocean_droplet.main # ปลายทาง: resource ใน module ชื่อ slippass
  id = "605234164"                               # ตัวจริงที่จะรับมา (id ของ Droplet จากหน้า DO)
}
