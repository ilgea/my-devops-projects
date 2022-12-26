#! /bin/bash
yum update -y
# yum install python3 -y
# pip3 install flask
# pip3 install flask_mysql
# yum install git -y
echo "${aws_s3_bucket.hoop.bucket}" > /home/ec2-user/dbserver.endpoint
# echo ${aws_db_instance.rds.address} > /home/ec2-user/dbserver.endpoint
# TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# cd /home/ec2-user && git clone https://$TOKEN@github.com/ilgea/karakalem.git
# python3 /home/ec2-user/karakalem/phonebook-app.py
# # cd /home/ec2-user && git clone https://$TOKEN@github.com/ilgea/karakalem.git
# # FOLDER="https://$TOKEN@raw.githubusercontent.com/serdarcw/phonebook_app/master"
# # FOLDER="https://$TOKEN@raw.githubusercontent.com/ilgea/karakalem/main"
# FOLDER="https://$TOKEN@raw.githubusercontent.com/ilgea/karakalem/main"
# curl -s --create-dirs -o "/home/ec2-user/templates/index.html" -L "$FOLDER"/templates/index.html
# curl -s --create-dirs -o "/home/ec2-user/templates/add-update.html" -L "$FOLDER"/templates/add-update.html
# curl -s --create-dirs -o "/home/ec2-user/templates/delete.html" -L "$FOLDER"/templates/delete.html
# curl -s --create-dirs -o "/home/ec2-user/app.py" -L "$FOLDER"/phonebook-app.py
# python3 /home/ec2-user/app.py


# # https://$TOKEN@raw.githubusercontent.com/ilgea/karakalem/main/templates/add-update.html

# # https://$TOKEN@raw.githubusercontent.com/ilgea/karakalem/main/phonebook-app.py

# cd /home/ec2-user && git clone https://$TOKEN@github.com/ilgea/karakalem.git
# python3 /home/ec2-user/phonebook/phonebook-app.py