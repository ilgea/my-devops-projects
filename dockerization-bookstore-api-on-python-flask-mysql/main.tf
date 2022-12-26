data "aws_vpc" "selected" {
  default = true

}

data "aws_subnets" "example" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

}

data "aws_ami" "amazon-linux-2" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


resource "aws_instance" "bookstore-server" {
  instance_type   = "t2.micro"
  ami             = data.aws_ami.amazon-linux-2.id
  key_name        = "firstkey"
 vpc_security_group_ids = [ aws_security_group.server-sg.id ]
  tags = {
    "Name" = "bookstore-webserver"
  }
  user_data = <<EOF
            #! /bin/bash
            yum update -y
            yum install git -y
            amazon-linux-extras install docker -y
            systemctl start docker
            systemctl enable docker
            usermod -a -G docker ec2-user
            # install docker-compose
            curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)" \
            -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
            
            docker-compose up -d
EOF
}

output "ip-adress" {
  value = aws_instance.bookstore-server.public_ip
}