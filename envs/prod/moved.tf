# บอก Terraform ว่า "ไม่ได้ลบ แค่เปลี่ยนชื่อ module จาก slipplus เป็น slippass"
# state ใน HCP จำชื่อเก่า (module.slipplus.*) ไว้ ถ้าไม่มีบล็อกนี้ Terraform จะเห็นของเก่าเป็นส่วนเกิน
# แล้วสั่งลบ (รวม Droplet จริง!) และสร้างของใหม่ตามชื่อใหม่
# บล็อกนี้ย้ายทุกอย่างใน module เก่ามาชื่อใหม่ โดยไม่แตะของจริง (ย้ายแค่ "ป้ายชื่อใน state")
# เก็บไว้จน apply สำเร็จอย่างน้อย 1 รอบ แล้วค่อยลบไฟล์นี้ได้
moved {
  from = module.slipplus
  to   = module.slippass
}
