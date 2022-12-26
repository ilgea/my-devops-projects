resource "aws_security_group" "ec2-sec-grp" {
  name = "webserver-sec-grp"
  vpc_id = data.aws_vpc.default.id
  tags = {
    "Name" = "webserver-sec-grp"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    # security_groups = [aws_security_group.alb-sg.id]
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    security_groups = [aws_security_group.alb-sg.id]
    # cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb-sg" {
  name = "ALBSecurityGroup"
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name = "ALBSecurityGroup"
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "db-sec-grp" {
  name = "rds-sec-grp"
  vpc_id = data.aws_vpc.default.id
  tags = {
    "Name" = "rds-sec-grp"
  }
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [ aws_security_group.ec2-sec-grp.id ]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}