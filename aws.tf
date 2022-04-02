terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
    region = "us-east-1"
    profile = "default"
}

resource "aws_instance" "consul-server" {
    count = 1
    ami           = "ami-03c2b308f588bcd39"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.consul-sg.id]
    key_name = "consul-key"
    tags = {
        Name = "consul-server-0${count.index+1}"
    }

    ebs_block_device {
        delete_on_termination = true
        device_name = "/dev/sda1"
        volume_size = 25
    }

    user_data = <<-EOL
    #!/bin/bash -xe
    sudo su
    sudo hostnamectl set-hostname "consul-server-0${count.index+1}"
    sudo rm /etc/consul.d/consul.hcl
    sudo touch /etc/consul.d/consul.hcl
    sudo chown consul.consul /etc/consul.d/consul.hcl

    sudo echo "data_dir = \"/etc/consul.d/consul-dir"\" > /etc/consul.d/consul.hcl
    sudo echo "bind_addr = \"$(eval hostname -I | xargs)"\" >> /etc/consul.d/consul.hcl
    sudo echo "server = true" >> /etc/consul.d/consul.hcl
    sudo echo "ui_config = {enabled = true}" >> /etc/consul.d/consul.hcl
    sudo echo "bootstrap_expect = 1" >> /etc/consul.d/consul.hcl
    sudo echo "client_addr = [\"0.0.0.0""\"]" >> /etc/consul.d/consul.hcl
    sudo echo "node_name =  \"consul-server"\" >> /etc/consul.d/consul.hcl

    sudo systemctl start consul
    EOL

}

resource "aws_instance" "consul-client" {
    count = 1
    ami           = "ami-03c2b308f588bcd39"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.consul-sg.id]
    key_name = "consul-key"
    tags = {
        Name = "consul-client-0${count.index+1}"
    }

    ebs_block_device {
        delete_on_termination = true
        device_name = "/dev/sda1"
        volume_size = 25
    }

    user_data = <<-EOL
    #!/bin/bash -xe
    sudo su
    sudo hostnamectl set-hostname "consul-client-0${count.index+1}"
    sudo rm /etc/consul.d/consul.hcl
    sudo touch /etc/consul.d/consul.hcl

    sudo chown consul.consul /etc/consul.d/consul.hcl
    sudo echo "data_dir = \"/etc/consul.d/consul-dir"\" > /etc/consul.d/consul.hcl
    sudo echo "bind_addr = \"$(eval hostname -I | xargs)"\" >> /etc/consul.d/consul.hcl

    sudo systemctl start consul

    EOL

}

resource "aws_security_group" "consul-sg" {
  name = "consul-sg"
  
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}