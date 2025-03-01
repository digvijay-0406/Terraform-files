provider "aws" {
  region = "ap-south-1"
}
resource "aws_instance" "myec2" {
  ami                    = var.myami
  instance_type          = var.instype
  key_name               = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [aws_security_group.mysg.id]
  tags = {
    Name = "MyNewterra"
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.myec2.public_ip} > ip.txt"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start",
      "cd /usr/share/nginx/html",
      "sudo touch sonu.html",
      "echo 'Hello Bhai Kaise ho' | sudo tee sonu.html"
    ]
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.rsa.private_key_pem
    host        = self.public_ip
  }
}
resource "aws_security_group" "mysg" {
  name   = "mysg"
  vpc_id = "vpc-0e9a63ab4281711fa"
  ingress {
    from_port   = 22
    to_port     = 22
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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "mykey" {
  key_name   = "mycustomkey"
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "mykey" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "mycustomkey.pem"
}
