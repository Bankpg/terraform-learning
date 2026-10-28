# STEP 1 ของ "เริ่มใหม่": สั่งให้ Terraform "ลืม" 3 รายการนี้ โดยไม่ลบของจริงบน Droplet
# (destroy = false = แค่ลบออกจาก state คอนเทนเนอร์/ไฟล์บนเครื่องไม่ถูกแตะ)
# ต้องปิดโค้ดของ resource เหล่านี้ไว้ก่อน (ไฟล์ *.step1 ใน modules/slippass-stack) ถึงจะใช้ removed ได้
# STEP 2: หลัง apply สำเร็จ ให้ลบไฟล์นี้ แล้วเปลี่ยนชื่อ services.tf.step1 / proxy.tf.step1 กลับเป็น .tf
removed {
  from = module.slippass.terraform_data.registry_login
  lifecycle {
    destroy = false
  }
}

removed {
  from = module.slippass.terraform_data.service
  lifecycle {
    destroy = false
  }
}
