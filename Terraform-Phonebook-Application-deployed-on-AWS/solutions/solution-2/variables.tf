data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# variable "my_ami" {
#   default = "ami-09d3b3274b6c5d4aa"
# }

variable "my_ins_type" {
  default = "t2.micro"
}

variable "my_key" {
  default = "keyname"

}
