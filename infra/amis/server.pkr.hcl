packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.9"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "amazon-ami" "latest-al2023" {
  filters = {
    virtualization-type = "hvm"
    name                = "al2023-ami-minimal-2023.*-arm64"
    root-device-type    = "ebs"
  }
  owners      = ["137112412989"]
  most_recent = true
}

source "amazon-ebs" "server" {
  region               = "us-west-2"
  profile              = "packer"
  source_ami           = data.amazon-ami.latest-al2023.id
  subnet_id            = "subnet-05c2105bfad11abf9"
  instance_type        = "t4g.small"
  ssh_username         = "ec2-user"
  security_group_id    = "sg-081613d174e1f8e8b" # the public ssh access group for now
  imds_support         = "v2.0"
  ami_name             = "server {{timestamp}}"
  iam_instance_profile = "server"
}

build {
  sources = [
    "source.amazon-ebs.server"
  ]

  provisioner "file" {
    source      = "server_scripts"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline = ["sudo bash -xe /tmp/server_scripts/setup.sh"]
  }

  provisioner "shell" {
    inline = ["sudo rm -rf /tmp/*"]
  }
}