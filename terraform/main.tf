--- terraform/main.tf ---

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c02fb55956c7d316"  
  instance_type = "t2.micro"
  key_name      = var.key_name

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y || sudo apt update -y",
      "sudo yum install docker -y || sudo apt install docker.io -y",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user || sudo usermod -aG docker ubuntu",
      "sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  tags = {
    Name = "java-docker-app-server"
  }
}

