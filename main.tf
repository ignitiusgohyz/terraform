provider "aws" {
  region = "ap-southeast-1"
}

# Launch template for ASG to launch ec2 instance
resource "aws_launch_template" "windows_template" {
  # Windows AMI
  image_id = "ami-02a548e73be1904e2"

  # Amazon Linux AMI
  # image_id               = "ami-0eeadc4ab092fef70"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.server_sg.id]

  #Powershell Script
  user_data = base64encode(file("${path.module}/powershell.ps1"))

  # Linux Shell Script
  # user_data = base64encode(file("${path.module}/shell.sh"))
}

resource "aws_vpc" "vpc" {
  cidr_block = "172.31.0.0/16"
  tags = {
    Name = "vpc-ig"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw-ig"
  }
}

# Routing of traffic between public internet and VPC via internet gateway
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "routetable-ig"
  }
}

# Creating subnets in different AZs
resource "aws_subnet" "subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "172.31.0.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"
  tags = {
    Name = "subnet-1a-ig"
  }
}

resource "aws_subnet" "subnet_1b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "172.31.16.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1b"
  tags = {
    Name = "subnet-1b-ig"
  }
}

resource "aws_subnet" "subnet_1c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "172.31.32.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1c"
  tags = {
    Name = "subnet-1c-ig"
  }
}

# Creating routes in route table
resource "aws_route_table_association" "subnet_1a_route" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnet_1a.id
}

resource "aws_route_table_association" "subnet_1b_route" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnet_1b.id
}

resource "aws_route_table_association" "subnet_1c_route" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnet_1c.id
}

# Security group for EC2 instances (Control traffic)
resource "aws_security_group" "server_sg" {
  vpc_id = aws_vpc.vpc.id

  # HTTP from ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # From within VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  # From SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP to outside
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg-ig"
  }
}
