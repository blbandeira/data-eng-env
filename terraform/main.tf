terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region                   = "us-east-2"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "vscode"
}


#Security group to access EC2 from anywhere
resource "aws_security_group" "de_security_group" {
  name        = "de_security_group"
  description = "Security Group to Allow inbound SCP & outbound 8080 connections"

  ingress {
    description = "Inbound SCP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow access to Metabase from perosnal PC"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Allow access to Airflow UI from perosnal PC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "de_security_group"
  }
}

resource "tls_private_key" "custom_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name_prefix = var.key_name
  public_key      = tls_private_key.custom_key.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220420"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "de_ec2" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.de_security_group.name]
  tags = {
    Name = "de_ec2"
  }

  user_data = <<EOF
#!/bin/bash
echo "-------------------------START SETUP---------------------------"

sudo apt-get -y update
sudo apt-get -y install \
ca-certificates \
curl \
gnupg \
lsb-release
sudo apt -y install unzip
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo chmod 666 /var/run/docker.sock
sudo apt install make
echo 'Clone git repo to EC2'
cd /home/ubuntu && git clone ${var.repo_url}
echo 'CD to repo directory'
cd ${var.repo_name}
echo 'Start containers & Run db migrations'
make up

echo "-------------------------END SETUP---------------------------"
EOF
}


resource "aws_budgets_budget" "ec2" {
  name              = "budget-ec2"
  budget_type       = "COST"
  limit_amount      = "20"
  limit_unit        = "USD"
  time_period_end   = "2087-06-15_00:00"
  time_period_start = "2023-01-18_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}


