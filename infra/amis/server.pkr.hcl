packer {
  required_version = ">= 1.10.0"

  required_plugins {
    amazon = {
      version = ">= 1.3.0"
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
  subnet_id            = "subnet-094aa23f1f145f81a"
  instance_type        = "t4g.small"
  ssh_username         = "ec2-user"
  ssh_interface        = "private_ip"
  security_group_ids = [
    "sg-0f33b9d9f0b048328", # packer-instance
    "sg-0fe92a5c593a480c2", # packer-fargate-ssh
    "sg-06315c442e768445b", # tailscale-ssh-access
  ]
  imds_support         = "v2.0"
  encrypt_boot         = true
  ami_name             = "server {{timestamp}}"
  iam_instance_profile = "server"
  deprecate_at         = timeadd(timestamp(), "240h")
  ami_description      = "created from ${data.amazon-ami.latest-al2023.id}"
  run_tags = {
    Name = "server {{timestamp}}"
  }
  snapshot_tags = {
    Name = "server {{timestamp}}"
  }
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

  post-processor "manifest" {
    output     = "output/server_manifest.json"
    strip_path = true
  }
}