# Identify Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.33.0"
    }
  }
}

# VPC
resource "aws_vpc" "wk18" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "wk18"
  }
}

# Public Subnets (2)
resource "aws_subnet" "public_subnet1a_wk18" {
  vpc_id            = aws_vpc.wk18.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public subnet 1a_wk18"
  }
}

resource "aws_subnet" "public_subnet1b_wk18" {
  vpc_id            = aws_vpc.wk18.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "public subnet 1b_wk18"
  }
}

# Private Subnets (2)
resource "aws_subnet" "private_subnet_1a_wk18" {
  vpc_id                  = aws_vpc.wk18.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "private subnet 1a_wk18"
  }
}
resource "aws_subnet" "private_subnet_1b_wk18" {
  vpc_id                  = aws_vpc.wk18.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "private subnet 1b_wk18"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "wk18_ig" {
  tags = {
    Name = "wk18_internet_gateway"
  }
  vpc_id = aws_vpc.wk18.id
}

# Route Table
resource "aws_route_table" "wk18_rt" {
  tags = {
    Name = "wk18_route_table"
  }
  vpc_id = aws_vpc.wk18.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wk18_ig.id
  }
}

# Route Table Association
resource "aws_route_table_association" "wk18_route_table_assoc" {
  subnet_id      = aws_subnet.public_subnet1a_wk18.id
  route_table_id = aws_route_table.wk18_rt.id
}

resource "aws_route_table_association" "wk18_route_table_assoc2" {
  subnet_id      = aws_subnet.public_subnet1b_wk18.id
  route_table_id = aws_route_table.wk18_rt.id
}

# VPC Security Group
resource "aws_security_group" "wk18_sg_public" {
  name        = "wk18_sg_public"
  description = "Allow traffic from VPC"
  vpc_id      = aws_vpc.wk18.id
  depends_on = [
    aws_vpc.wk18
  ]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
  }
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wk18_vpc"
  }
}

# Load balancer security group
resource "aws_security_group" "wk18_sg_auto_lb" {
  name        = "wk18_sg_auto_lb"
  description = "load balancer security group"
  vpc_id      = aws_vpc.wk18.id
  depends_on = [
    aws_vpc.wk18
  ]


  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "wk18_sg_auto_lb"
  }
}

# Public subnet 1 EC2 instance
resource "aws_instance" "web_server1_wk18" {
  ami             = "ami-026b57f3c383c2eec"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.wk18_sg_public.id]
  subnet_id       = aws_subnet.public_subnet1a_wk18.id

  user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start
        systemctl enable
        echo '<p style="text-align: center;"><strong>Job well done! You now know how to use Terraform in ASW!</strong></p>
<p><img style="display: block; margin-left: auto; margin-right: auto;" src="https://i.ibb.co/0GtKzQy/Terraform-artwork.png" alt="" width="1055" height="514" /></p>' > /usr/share/nginx/html/index.html
        EOF
}

# Public subnet 2 EC2 instance
resource "aws_instance" "web_server2_wk18" {
  ami             = "ami-026b57f3c383c2eec"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.wk18_sg_public.id]
  subnet_id       = aws_subnet.public_subnet1b_wk18.id

  user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start
        systemctl enable 
        echo '<p style="text-align: center;"><strong>Job well done! You now know how to use Terraform in ASW!</strong></p>
<p><img style="display: block; margin-left: auto; margin-right: auto;" src="https://i.ibb.co/0GtKzQy/Terraform-artwork.png" alt="" width="1055" height="514" /></p>' > /usr/share/nginx/html/index.html
        EOF
}
# Create Load balancer
resource "aws_lb" "lb_wk18" {
  name               = "lb-wk18"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wk18_sg_public.id]
  subnets            = [aws_subnet.public_subnet1a_wk18.id, aws_subnet.public_subnet1b_wk18.id]

  tags = {
    Environment = "wk18"
  }
}

resource "aws_lb_target_group" "wk18_target_grp" {
  name     = "wk18-project-tf"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.wk18.id
}

# Create Auto Load Balancer listener
resource "aws_lb_listener" "wk18_loadb" {
  load_balancer_arn = aws_lb.lb_wk18.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loadb_target.arn
  }
}

# Create Target group
resource "aws_lb_target_group" "loadb_target" {
  name       = "target"
  depends_on = [aws_vpc.wk18]
  port       = "80"
  protocol   = "HTTP"
  vpc_id     = aws_vpc.wk18.id
  health_check {
    interval            = 70
    path                = "/var/www/html/index.html"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 60
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}
resource "aws_lb_target_group_attachment" "acquire_targets_mki" {
  target_group_arn = aws_lb_target_group.loadb_target.arn
  target_id        = aws_instance.web_server1_wk18.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "acquire_targets_mkii" {
  target_group_arn = aws_lb_target_group.loadb_target.arn
  target_id        = aws_instance.web_server2_wk18.id
  port             = 80
}

# Subnet group database
resource "aws_db_subnet_group" "database_subnet" {
  name       = "database_subnet"
  subnet_ids = [aws_subnet.private_subnet_1a_wk18.id, aws_subnet.private_subnet_1b_wk18.id]
}

# Database tier Security gruop
resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "allow traffic from internet"
  vpc_id      = aws_vpc.wk18.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.wk18_sg_public.id]
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.wk18_sg_public.id]
    cidr_blocks     = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private subnet 1 database
resource "aws_db_instance" "db1" {
  allocated_storage           = 5
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t2.micro"
  db_subnet_group_name        = "database_subnet"
  vpc_security_group_ids      = [aws_security_group.database_sg.id]
  parameter_group_name        = "default.mysql5.7"
  db_name                     = "database_wk18"
  username                    = "admin"
  password                    = "password"
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  backup_retention_period     = 35
  backup_window               = "22:00-23:00"
  maintenance_window          = "Sat:00:00-Sat:03:00"
  multi_az                    = false
  skip_final_snapshot         = true
}