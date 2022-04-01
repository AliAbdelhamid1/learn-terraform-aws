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

resource "aws_instance" "consul" {
    count = 2
    ami           = "ami-03c2b308f588bcd39"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.consul-sg.id]
    key_name = "consul-key"
    tags = {
        Name = "consul-0${count.index+1}"
    }

    ebs_block_device {
        delete_on_termination = true
        device_name = "/dev/sda1"
        volume_size = 25
    }

    user_data = <<-EOL
    #!/bin/bash -xe
    sudo hostnamectl set-hostname "consul-${count.index+1}"
    EOL

}

resource "aws_security_group" "consul-sg" {
  name = "consul-ui"
  
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
}