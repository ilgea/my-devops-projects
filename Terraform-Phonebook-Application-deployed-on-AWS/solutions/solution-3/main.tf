# data bloğu halihazırda var olan resource'un bilgilerini verir. Biz var olan'ı (default vpc) kullanacağımız için data bloğunu kullanıyoruz.
data "aws_vpc" "selected" {
  default = true
}

# Bize default vpc'nin subnetlerini verecek. Bunu Load Balancer'da kullanacağız.
data "aws_subnets" "my-subnet" {
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.selected.id ]
  }
}

# amazon linux 2'nin ami'ini alıyoruz. Her uygulama için belirli bir AMI kullanamak best-practise'dir.
data "aws_ami" "amazon-linux-2" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_db_instance" "db-server" {
  instance_class = "db.t2.micro"
  allocated_storage = 20
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  allow_major_version_upgrade = false # büyük versiyon değişikliklerini otomatik yapmasın
  auto_minor_version_upgrade = true # küçük versiyon değişikliklerini otomatik yapsın.
  backup_retention_period = 0 # backup'ları tutmasın dedik.
  identifier = "phonebook-app-db" # Oluşacak db instance'ın ismi.
  db_name = "phonebook" # MYSQL_DATABASE_DB ile aynı isimde olması lazım.
  engine = "mysql"
  engine_version = "8.0.31"
  username = "ilgea" # MYSQL_DATABASE_USER kısmı.
  password = "ilgea_pass" # MYSQL_DATABASE_PASSWORD kısmı.
  monitoring_interval = 0 # Sürekli logları detaylı izlemesin diyoruz.
  multi_az = false
  port = 3306 # yazmasakda olur. Zaten default'u 3306.
  publicly_accessible = false # public olarak erişilemesin diyoruz.
  skip_final_snapshot = true # Silmeden önce snapshot oluşturma diyoruz.
}


# Token ile hesabıma bağlanacak. pb-with-terraform isimli repo'ya gidecek. Orada dbendpoint isimli bir dosya oluşturacak. Bu dosyanın içeriğide content kısmından gelecek. Yani db-server'ın adresi olacak.
resource "github_repository_file" "dbendpoint" {
  content = aws_db_instance.db-server.address
  file = "dbserver.endpoint"
  repository = "pb-with-terraform"
  overwrite_on_create = true
  branch = "main" # repo'nun branşı ne ise onu yazıyoruz.
  depends_on = [ aws_db_instance.db-server ]
}

resource "aws_launch_template" "lt-for-asg" {
  name = "pb-lt"
  image_id = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  key_name = "key-name"
  vpc_security_group_ids = [ aws_security_group.server-sg.id ]
  user_data = filebase64("user-data.sh")
  depends_on = [ github_repository_file.dbendpoint ] # github'daki bu dosya oluşmadan lt'i çalıştırma.
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Web Server of Phonebook"
    }
  }
}

resource "aws_alb_target_group" "app-lb-tg" {
  name = "phonebook-lb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.selected.id
  target_type = "instance"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}

resource "aws_alb" "app-lb" {
  name = "phonebook-lb-tf"
  ip_address_type = "ipv4"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb-sg.id]
  subnets = data.aws_subnets.my-subnet.ids  # birden fazla kullanmak için ids yazıyoruz.
}

resource "aws_alb_listener" "app-listener" {
  load_balancer_arn = aws_alb.app-lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.app-lb-tg.arn
  }
}

resource "aws_autoscaling_group" "app-asg" {
  max_size = 3
  min_size = 1
  desired_capacity = 2
  name = "phonebook-asg"
  health_check_grace_period = 300
  health_check_type = "ELB"
  target_group_arns = [ aws_alb_target_group.app-lb-tg.arn ]
  vpc_zone_identifier = aws_alb.app-lb.subnets
  launch_template {
    id = aws_launch_template.lt-for-asg.id
    version = aws_launch_template.lt-for-asg.latest_version # versiyonda seçmek gerekiyor. Son versiyonu kullan diyoruz.
  }
}
# Aşağıdaki blok ile mevcut hosted zone'unu tanımlayabiliyor, zone id gibi gereklilikleri alabiliyorsun.
data "aws_route53_zone" "my-zone" {
  name         = "cloudilgea.link" # zorunlu kısım.
  # private_zone = false # public ise false yapıyorsun.
}


resource "aws_route53_record" "book-site" {
  zone_id = data.aws_route53_zone.my-zone.zone_id # Bu record'un bulunduğu hosted zone'un id'si. Zorunlu alan.
  name    = "my-phonebook.cloudilgea.link" # record'un ismi. Zorunlu alan.
  type    = "A" # Zorunlu alan.

  alias {
    name                   = aws_alb.app-lb.dns_name # Record'a eklediğimiz ALB'nin dns adresi. Zorunlu alan.
    zone_id                = aws_alb.app-lb.zone_id  # Hosted zone id for alb. Zorunlu alan
    evaluate_target_health = true # Zorunlu alan.
  }
}