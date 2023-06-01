variable "mykey" {
  default = "mykey"
}
variable "myami" {
  default = "ami-026b57f3c383c2eec"
}
variable "instancetype" {
  default = "t3a.small"
}
variable "tag" {
  default = "Jenkins_Server"
}
variable "jenkins-sg" {
  default = "jenkins-server-sec-gr-208"
}

variable "user" {
  default = "ilgea"
}