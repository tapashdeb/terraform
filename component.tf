# Provider selection

provider "aws"  {
    region = "us-east-1"
    access_key = "Apply your access ID"
    secret_key = "Apply your secret key"  
}


#VPC Creation

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  

  tags = {
    Name = "myvpc"
  }
}

# security group creation

resource "aws_security_group" "mysecurity" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysecuritygrp"
  }
}

# Subnet Creation

resource "aws_subnet" "Public_Subnet_1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
  enable_resource_name_dns_a_record_on_launch = "true"

  tags = {
    Name = "Public Subnet-1"
  }
}


resource "aws_subnet" "Public_Subnet_2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"
  enable_resource_name_dns_a_record_on_launch = "true"

  tags = {
    Name = "Public Subnet-2"
  }
}

resource "aws_subnet" "Public_Subnet_3" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.10.3.0/24"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = "true"
  enable_resource_name_dns_a_record_on_launch = "true"

  tags = {
    Name = "Public Subnet-3"
  }
}

resource "aws_subnet" "Private_subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.10.4.0/24"
  availability_zone = "us-east-1d"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "private subnet"
  }
}

# Internet gateway creation

resource "aws_internet_gateway" "myingw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myingw"
  }
}

# Route Table Creation

resource "aws_route_table" "myroutetable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myingw.id
  }
}

# Subnet association

resource "aws_route_table_association" "Public_Subnet_1" {
  subnet_id      = aws_subnet.Public_Subnet_1.id
  route_table_id = aws_route_table.myroutetable.id
}

resource "aws_route_table_association" "Public_Subnet_2" {
  subnet_id      = aws_subnet.Public_Subnet_2.id
  route_table_id = aws_route_table.myroutetable.id
}

resource "aws_route_table_association" "Public_Subnet_3" {
  subnet_id      = aws_subnet.Public_Subnet_3.id
  route_table_id = aws_route_table.myroutetable.id
}


#EC2 creation

resource "aws_instance" "Jenkins_server" {
  ami                     = "ami-06a0cd9728546d178"
  instance_type           = "t2.micro"
  key_name = "terraform-key"
  subnet_id = aws_subnet.Public_Subnet_1.id
  security_groups = [aws_security_group.mysecurity.id]

  user_data = file("jenkins.sh")

  tags = {
    Name="Jenkins-Server"
  }
}


resource "aws_instance" "docker-host" {
  ami                     = "ami-06a0cd9728546d178"
  instance_type           = "t2.micro"
  subnet_id = aws_subnet.Public_Subnet_2.id
  key_name = "terraform-key"
  security_groups = [aws_security_group.mysecurity.id]

  user_data = file("docker.sh")
  tags = {
    Name="Docker-host"
  }
}

resource "aws_instance" "kubernetes" {
  ami                     = "ami-06a0cd9728546d178"
  instance_type           = "t2.medium"
  key_name = "terraform-key"
  subnet_id = aws_subnet.Public_Subnet_3.id
  security_groups = [aws_security_group.mysecurity.id]


  user_data = file("kubernetes.sh")

  tags = {
    Name="Kubernetes_server"
  }
}

resource "aws_instance" "Database_Server" {
  ami                     = "ami-06a0cd9728546d178"
  instance_type           = "t2.micro"
  key_name = "terraform-key"
  subnet_id = aws_subnet.Private_subnet.id
  security_groups = [aws_security_group.mysecurity.id]

  tags = {
    Name="Database_Server"
  }
}






