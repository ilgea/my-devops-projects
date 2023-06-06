data "aws_ami" "amazon-linux-2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm*"]
  }
}


# resource "aws_instance" "deneme-ec2" {
#   instance_type   = "t2.micro"
#   ami             = "ami-09d3b3274b6c5d4aa"
#   key_name        = "keyname"
#   security_groups = [aws_security_group.deneme_sec_grp.name]
#   tags = {
#     "Name" = "deneme-ec2"
#   }
#   user_data = <<EOF
# #! /bin/bash
# yum update -y
# yum install python3 -y
# pip3 install flask
# pip3 install flask_mysql
# yum install git -y
# TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# cd /home/ec2-user && git clone https://$TOKEN@github.com/ilgea/karakalem.git
# echo "${aws_db_instance.rds.address}" > /home/ec2-user/karakalem/dbserver.endpoint
# python3 /home/ec2-user/karakalem/phonebook-app.py
# EOF
#   # user_data = filebase64("userdata.sh")
#   depends_on = [
#     aws_db_instance.rds
#   ]
# }

resource "aws_lb" "alb" {
  name               = "phonebook-app"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = data.aws_subnets.subnet.ids
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  internal           = false
}

resource "aws_lb_target_group" "turgut" {
  name        = "phonebook-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.default.id
  # Alter the destination of the health check to be the login page.
  health_check {
    enabled             = true
    unhealthy_threshold = 3
    healthy_threshold   = 2
    interval            = 10
  }
}

resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.turgut.arn
    type             = "forward"
  }
}

resource "aws_autoscaling_group" "WebserverASG" {
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 2
  name                      = "phonebook-asg"
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.turgut.arn]
  vpc_zone_identifier       = aws_lb.alb.subnets

  launch_template {
    id = aws_launch_template.my-temp.id
    version = aws_launch_template.my-temp.latest_version
  }
}

resource "aws_launch_template" "my-temp" {
  name                   = "phonebook-lt"
  image_id               = data.aws_ami.amazon-linux-2.id
  instance_type          = var.my_ins_type
  key_name               = var.my_key
  vpc_security_group_ids = [aws_security_group.ec2-sec-grp.id]
  placement {
    # availability_zone = "us-east-1"
  }
  
    tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = "Web server of Phonebook App"
    }
  }
  # user_data = filebase64("userdata.sh")
  user_data = "${base64encode(<<EOF
#!/bin/bash
yum update -y
yum install python3 -y
pip3 install flask
pip3 install flask_mysql
yum install git -y
TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
cd /home/ec2-user && git clone https://$TOKEN@github.com/clarusway-aws-devops/project-202-ilgea.git
echo "${aws_db_instance.rds.address}" > /home/ec2-user/project-202-ilgea/dbserver.endpoint
python3 /home/ec2-user/project-202-ilgea/phonebook-app.py
EOF
)}"
  depends_on = [
    aws_db_instance.rds
  ]
}

resource "aws_db_instance" "rds" {
  allocated_storage      = 20
  db_name                = "phonebook"
  engine                 = "mysql"
  engine_version         = "8.0.25"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = "ilgea"
  identifier             = "phonebook-app-db"
  skip_final_snapshot    = true
  port                   = 3306
  vpc_security_group_ids = ["${aws_security_group.db-sec-grp.id}"]
}

# resource "github_repository_file" "dbendpoint" {
#   content = aws_db_instance.rds.address
#   file = "dbserver.endpoint"
#   repository = "karakalem"
#   overwrite_on_create = true
#   branch = "main"
# }

output "rds-endpoint" {
  value = aws_db_instance.rds.address
}

output "lb-dns-name" {
  value = "http://${aws_lb.alb.dns_name}"
}