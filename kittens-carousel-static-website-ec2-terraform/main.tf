terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.1.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # Configuration options
}

data "aws_ami" "amazon-2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

}

variable "secgr-dynamic-ports" {
  default = [22, 80, 443]
}

variable "instance-type" {
  default   = "t2.micro"
  sensitive = true
}

resource "aws_instance" "kitten-carusel" {
  ami = data.aws_ami.amazon-2.id
  key_name               = "my-key"
  instance_type          = var.instance-type
  vpc_security_group_ids = [aws_security_group.http-ssh.id]
  user_data              = file("carusel.sh")
  tags = {
    Name = "carusel"
  }
}

resource "null_resource" "exec" {
  depends_on = [ aws_instance.kitten-carusel ]

  provisioner "file" {
    source = "./static-web"
    destination = "/home/ec2-user/carusel-static/"
    when = create
  }

  provisioner "remote-exec" {
    inline = ["sleep 60s && sudo cp -r /home/ec2-user/carusel-static/* /var/www/html/"]
  }

  provisioner "remote-exec" {
    inline = ["sudo systemctl restart httpd"]
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("C:\\Users\\ilgea\\.ssh\\my-key.pem")
    host = aws_instance.kitten-carusel.public_ip
  }

}

resource "aws_security_group" "http-ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  dynamic "ingress" {
    for_each = var.secgr-dynamic-ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Outbound Allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


output "ip-adress" {
  value = aws_instance.kitten-carusel.public_ip
}