provider "aws" {
  region = var.region
}


resource "aws_vpc" "dev-vpc" {
  cidr_block           = var.vpc-cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.envname}-vpc"
  }
}

#create Internet Gateway and attach to Public Subnet
#Terraform Aws InternetGateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
     Name = "${var.envname}-IGW"
  }
}

# Create Public Subnet 1
# terraform aws create subnet
resource "aws_subnet" "pubsubnet-1" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = var.pubsubnet-1-cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
     Name = "${var.envname}-pub-sub-1"
  }
}

# Create Public Subnet 2
# terraform aws create subnet
resource "aws_subnet" "pubsubnet-2" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = var.pubsubnet-2-cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.envname}-pub-sub-2"
  }
}
# Create Route Table and Add Public Route
# terraform aws create route table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = {
     Name = "${var.envname}-pub-route-table"
  }
}
# Associate Public Subnet 1 to "Public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "pubsubnet-1-route-table-association" {
  subnet_id      = aws_subnet.pubsubnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}
# Associate Public Subnet 2 to "Public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "pubsubnet-2-route-table-association" {
  subnet_id      = aws_subnet.pubsubnet-2.id
  route_table_id = aws_route_table.public-route-table.id
}


resource "aws_eip" "ip" {
  vpc = true
}

resource "aws_eip" "ec2_eip" {
  vpc = true
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ip.id
  subnet_id     = aws_subnet.pubsubnet-2.id

  tags = {
     Name = "${var.envname}-natgateway"
  }
}
data "template_file" "my_script" {
  template = file("${path.module}/install_docker.sh")
}
resource "aws_instance" "react_flask_app" {
  ami             = var.ami
  instance_type   =  var.instance_type
  subnet_id       = aws_subnet.pubsubnet-1.id
  security_groups = ["${aws_security_group.react_flask_app_sg.id}"]
  key_name        = "${aws_key_pair.react_flask_key.key_name}"
  user_data = data.template_file.my_script.rendered
  tags = {
    Name = "${var.envname}-react-flask-app"
  }

}
resource "aws_eip_association" "eip_assoc" {
  instance_id = aws_instance.react_flask_app.id
  allocation_id = aws_eip.ec2_eip.id
}

resource "aws_key_pair" "react_flask_key" {
  key_name   = var.key_name
  public_key = var.public_key
}  
