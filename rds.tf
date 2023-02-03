provider "aws" {
    region = "ap-south-1"
}

resource "aws_db_instance" "default" {
    allocated_storage=20
    storage_type="gp2"
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class = "db.t2.micro"
    name = "wp_aws_db"
    username = "abhishek"
    password = var.password
    #identifier = var.id
    skip_final_snapshot = true
    #Allowing Public Access
    publicly_accessible = true
    #Attaching VPC Security Group
    vpc_security_group_ids = [aws_security_group.access_to_localhost.id]
    apply_immediately = true
    tags = {
    Name = "wp_aws_db"
    }
}
#Storing Current Machine's Public IP
data "http" "localhost_public_ip" {
  url = "http://ipv4.icanhazip.com"
}

#Creating Security Group that allow Minikube to connect  RDS
resource "aws_security_group" "access_to_localhost" {
  name        = "access_to_localhost"
  description = "Allow 3306 inbound traffic only for the public ip of the machine running this code"

  ingress {
    description = "3306 from Minikube"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    #Public ip of localhost is allowed
    cidr_blocks = ["${chomp(data.http.localhost_public_ip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "access_to_localhost"
  }
}

#Give  DNS Name of RDS Instance on terminal
output "dns" {
value = aws_db_instance.default.address
}
