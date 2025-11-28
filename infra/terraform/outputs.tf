output "manager_public_ip" {
  description = "IP público do nó manager"
  value       = aws_instance.manager.public_ip
}

output "worker_public_ips" {
  description = "IPs públicos dos nós worker"
  value       = [for w in aws_instance.worker : w.public_ip]
}

output "manager_instance_id" {
  description = "ID do manager"
  value       = aws_instance.manager.id
}

output "worker_instance_ids" {
  description = "IDs dos workers"
  value       = [for w in aws_instance.worker : w.id]
}

output "all_instance_public_ips" {
  description = "Todos os IPs públicos do cluster"
  value       = concat(
    [aws_instance.manager.public_ip],
    [for w in aws_instance.worker : w.public_ip]
  )
}
