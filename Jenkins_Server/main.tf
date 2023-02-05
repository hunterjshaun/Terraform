terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


data "aws_vpc" "default" {
  cidr_block = "172.31.0.0/16"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }


  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  
  tags = {
    Name = "JenkinsServer"
  }
}
