// https://www.christopherblack.net/2021-01-16-terraform-copy-files/
locals {
  phishing_files = fileset("../deps/muraena", "**/*")

  unique_phishing_dirs = distinct([for file in local.phishing_files : dirname("/home/ssm-user/MURAENA/${file}")])

  write_files_phishing = [for file in local.phishing_files : {
    path        = "/home/ssm-user/MURAENA/${file}"
    permissions = "0644"
    owner       = "root:root"
    encoding    = "gz+b64"
    content     = base64gzip(file("../deps/muraena/${file}"))
  }]

  cloud_config_phishing = <<-END
    #cloud-config
    ${jsonencode({
      "write_files": local.write_files_phishing,
      "runcmd": [
        flatten([for dir in local.unique_phishing_dirs : ["mkdir","-p","${dir}"]])
      ]
    })}
  END

  cloud_config_config = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/home/ubuntu/http_config.json"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("../deps/http_config.json")
    },
  ]
})}
  END
}

data "cloudinit_config" "mythic_v3_user_data" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "http_config.json"
    content      = local.cloud_config_config
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "install.sh"
    content      = <<-EOF
      #!/bin/bash
      sudo apt-get -qq update && sudo apt-get -qq install -y git apt-transport-https ca-certificates curl gnupg lsb-release make
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get -qq update && sudo apt-get -qq install -y docker-ce docker-ce-cli docker-compose containerd.io
      sudo git clone https://github.com/its-a-feature/Mythic /opt/Mythic
      cd /opt/Mythic && sudo make
      sudo /opt/Mythic/mythic-cli install github https://github.com/MythicAgents/apfell # macOS JXA agent
      sudo /opt/Mythic/mythic-cli install github https://github.com/MythicC2Profiles/http
      sudo /opt/Mythic/mythic-cli start
      sudo mv /home/ubuntu/http_config.json /var/lib/docker/volumes/http_volume/_data/http/c2_code/config.json
    EOF
  }

}

data "cloudinit_config" "phishing_user_data" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "cloudconfig_phishing.txt"
    content      = local.cloud_config_phishing
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "install.sh"
    content      = <<-EOF
      #!/bin/bash
      sudo snap install --classic go
      sudo apt-get -qq update && sudo apt-get -qq install -y git redis-server make curl
      sudo systemctl enable redis-server.service
      # modify configuration file in /etc/redis/redis.conf
      echo "maxmemory 256mb" | sudo tee -a /etc/redis/redis.conf  > /dev/null
      echo "maxmemory-policy allkeys-lru" | sudo tee -a /etc/redis/redis.conf  > /dev/null
      sudo systemctl restart redis-server.service
      sudo git clone https://github.com/kgretzky/evilginx2.git /opt/evilginx2
      sudo curl -L https://github.com/muraenateam/muraena/releases/download/v1.23/muraena_linux_arm64 --create-dirs --output /opt/muraena/muraena
      sudo chmod -R +rx /opt/muraena/
      sudo chown -R ssm-user:ssm-user /home/ssm-user/MURAENA/
      cd /opt/evilginx2 && sudo make && chmod +x build/evilginx
    EOF
  }

}

# Get the latest Ubuntu 22.04 LTS for ARM
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical's owner ID
}

resource "aws_instance" "mythic_v3" {
  instance_type        = var.aws_instance_type
  ami                  = data.aws_ami.ubuntu.id
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  user_data            = data.cloudinit_config.mythic_v3_user_data.rendered

  tags = {
    "Name"                          = var.mythic_v3_server_name
  }

  subnet_id                   = aws_subnet.my_private_subnet.id
  vpc_security_group_ids      = [aws_security_group.mythic_server.id]
  key_name                    = var.key_name
  associate_public_ip_address = false

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
  }

  metadata_options {
    http_tokens = "required"
  }

  lifecycle {
    ignore_changes = [ami]
  }

  depends_on = [aws_nat_gateway.my_nat_gw, aws_route_table.my_private_route_table]
}

resource "aws_instance" "phishing" {
  instance_type        = var.aws_instance_type
  ami                  = data.aws_ami.ubuntu.id
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  user_data            = data.cloudinit_config.phishing_user_data.rendered

  tags = {
    "Name"                          = var.phishing_server_name
  }

  subnet_id                   = aws_subnet.my_public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.phishing_server.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
  }

  metadata_options {
    http_tokens = "required"
  }

  lifecycle {
    ignore_changes = [ami]
  }

  depends_on = [aws_internet_gateway.my_igw, aws_route_table.my_public_route_table]
}