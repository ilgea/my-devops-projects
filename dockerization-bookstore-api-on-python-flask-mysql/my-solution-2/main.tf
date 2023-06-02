terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.1.0"
    }
    github = {
      source = "integrations/github"
      version = "5.26.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
  # Configuration options
}

provider "github" {
  # Configuration options
  token = var.github-token
}

resource "github_repository" "my-git-repo" {
  name        = "book-api"
  auto_init = true
  visibility = "private"
}

resource "github_repository_file" "my-book-files" {
  repository          = github_repository.my-git-repo.name
  branch              = "main"
  for_each = toset(var.files)
  content = file(each.value)
  file                = each.value
  commit_message      = "Managed by Terraform"
  overwrite_on_create = true
}

data "aws_ami" "amazon-linux-2" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "my-book-server" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = var.my-instance
  key_name = var.my-key
  vpc_security_group_ids = [ aws_security_group.book-server-sg.id ] 
  tags = {
    Name = "phonebook-server"
  }
  user_data = <<-EOF
    #! /bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user
    curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    mkdir -p /home/ec2-user/bookstore
    cd /home/ec2-user/bookstore
    TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    FOLDER="https://$TOKEN@raw.githubusercontent.com/ilgea/book-api/main/"
    curl -s -o bookstore-api.py -L "$FOLDER"bookstore-api.py
    curl -s -o Dockerfile -L "$FOLDER"Dockerfile
    curl -s -o docker-compose.yaml -L "$FOLDER"docker-compose.yaml
    curl -s -o requirements.txt -L "$FOLDER"requirements.txt
    docker-compose up -d
  EOF
}

resource "aws_security_group" "book-server-sg" {
  name        = "book-app-sg"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg
  }
}

output "book-website" {
  value = "http://${aws_instance.my-book-server.public_dns}"
}