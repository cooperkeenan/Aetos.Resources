output "vm_public_ip" {
  description = "Public IP of the dev VM"
  value       = module.dev_vm.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to dev VM"
  value       = module.dev_vm.ssh_connection
}
