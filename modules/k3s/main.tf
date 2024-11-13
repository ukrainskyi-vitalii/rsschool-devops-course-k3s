resource "aws_instance" "k3s_master" {
  ami             = var.ami_id
  instance_type   = "t2.micro"
  subnet_id       = var.public_subnet_id
  key_name        = var.ssh_key_name
  security_groups = [aws_security_group.k3s_sg.id]

  tags = {
    Name = "k3s-master"
  }
}

output "master_private_ip" {
  value = aws_instance.k3s_master.private_ip
}

output "k3s_master_ip" {
  value       = aws_instance.k3s_master.public_ip
  description = "Public IP of the k3s master instance"
}