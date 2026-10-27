output "id" {
  value       = digitalocean_droplet.this.id
  description = "Droplet ID"
}

output "ipv4_address" {
  value       = digitalocean_droplet.this.ipv4_address
  description = "Public IPv4 address of the Droplet"
}
