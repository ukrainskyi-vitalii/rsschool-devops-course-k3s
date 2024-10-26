resource "aws_instance" "k3s_master" {
  ami             = var.ami_id
  instance_type   = "t2.small"
  subnet_id       = var.public_subnet_id
  key_name        = var.ssh_key_name
  security_groups = [aws_security_group.k3s_sg.id]
  user_data = <<-EOF
    #!/bin/bash
    curl -sfL https://get.k3s.io | sh -

    # Install Helm
    wget https://get.helm.sh/helm-v3.9.0-linux-amd64.tar.gz
    tar -zxvf helm-v3.9.0-linux-amd64.tar.gz
    mv linux-amd64/helm /usr/local/bin/helm
  EOF

  tags = {
    Name = "k3s-master"
  }
}

output "master_private_ip" {
  value = aws_instance.k3s_master.private_ip
}
