variable "my-key" {
    default = "my-key"
}

variable "my-instance" {
    default = "t2.micro"
}

variable "sg" {
  default = "bookstore-sg"
}

variable "github-token" {
  default = "xxxxxxxxxxxxxxxxxxxxxxxx"
}

variable "files" {
  default = ["bookstore-api.py", "Dockerfile", "docker-compose.yaml", "requirements.txt"]
}