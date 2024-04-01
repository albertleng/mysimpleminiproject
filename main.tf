provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "albertleng_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "AlbertLengVPC"
  }
}

resource "aws_subnet" "albertleng_subnet" {
  vpc_id                  = aws_vpc.albertleng_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "AlbertLengSubnet"
  }
}

resource "aws_internet_gateway" "albertleng_igw" {
  vpc_id = aws_vpc.albertleng_vpc.id

  tags = {
    Name = "AlbertLengInternetGateway"
  }
}

resource "aws_route_table" "albertleng_route_table" {
  vpc_id = aws_vpc.albertleng_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.albertleng_igw.id
  }

  tags = {
    Name = "AlbertLengRouteTable"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.albertleng_subnet.id
  route_table_id = aws_route_table.albertleng_route_table.id
}

resource "aws_security_group" "albertleng_security_group" {
  vpc_id = aws_vpc.albertleng_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AlbertLengSecurityGroup"
  }
}

resource "aws_instance" "AlbertLeng-Webserver-1" {
  ami                         = "ami-0c101f26f147fa7fd"
  instance_type               = "t2.micro"
  key_name                    = "albert-ollama-test"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.albertleng_subnet.id
  vpc_security_group_ids      = [
    aws_security_group.albertleng_security_group.id
  ]

  tags = {
    Name = "AlbertLeng-Webserver-1"
  }
}

# create `AlbertLeng-Webserver-2"
resource "aws_instance" "AlbertLeng-Webserver-2" {
  ami                         = "ami-0c101f26f147fa7fd"
  instance_type               = "t2.micro"
  key_name                    = "albert-ollama-test"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.albertleng_subnet.id
  vpc_security_group_ids      = [
    aws_security_group.albertleng_security_group.id
  ]

  tags = {
    Name = "AlbertLeng-Webserver-2"
  }
}

resource "aws_instance" "albertleng_ansible_server" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t2.micro"
  key_name                    = "albert-ollama-test"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.albertleng_subnet.id
  vpc_security_group_ids      = [
    aws_security_group.albertleng_security_group.id
  ]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y python3-pip
              sudo python3 -m pip install --user ansible
              EOF

  tags = {
    Name = "albertleng-ansible-server"
  }
}
