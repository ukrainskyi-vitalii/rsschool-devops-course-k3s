output "k3s_master_ip" {
  value       = module.k3s.k3s_master_ip
  description = "Public IP of the k3s master instance from module"
}
