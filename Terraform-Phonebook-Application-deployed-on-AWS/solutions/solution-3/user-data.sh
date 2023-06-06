#! /bin/bash
yum update -y
yum install python3 -y
pip3 install flask
pip3 install flask_mysql
yum install git -y
TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxx"
cd /home/ec2-user && git clone https://$TOKEN@github.com/ilgea/pb-with-terraform.git
python3 /home/ec2-user/pb-with-terraform/phonebook-app.py