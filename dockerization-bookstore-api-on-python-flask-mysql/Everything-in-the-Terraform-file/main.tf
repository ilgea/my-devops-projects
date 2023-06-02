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
  key_name        = "keyname"
 vpc_security_group_ids = [ aws_security_group.server-sg.id ]
  tags = {
    "Name" = "bookstore-webserver"
  }
  user_data = <<EOF
#! /bin/bash
yum update -y
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
systemctl status docker
usermod -a -G docker ec2-user
newgrp docker
curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)" \
            -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
cd /home/ec2-user
echo -e 'version: "3.7"
services:
  database:
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: hoop123
      MYSQL_DATABASE: bookstore_db
      MYSQL_USER: ilgea
      MYSQL_PASSWORD: ilgea_pass
      
  mybookstore:
    image: ilgea/bookstore:latest
    restart: always
    depends_on:
      - database
    ports:
      - "80:80"' > docker-compose.yaml
docker-compose up -d
EOF
}

output "ip-adress" {
  value = "http://${aws_instance.bookstore-server.public_ip}"
}
