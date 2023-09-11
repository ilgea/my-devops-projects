#! /bin/bash

# yum update -y
yum update --security -y
hostnamectl set-hostname carusel
yum install httpd -y
systemctl start httpd
systemctl enable httpd
chmod -R 777 /var/www/html