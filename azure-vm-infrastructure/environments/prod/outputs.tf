output "vm_public_ip" {
  description = "Public IP of the prod VM"
  value       = module.prod_vm.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to prod VM"
  value       = module.prod_vm.ssh_connection
}

