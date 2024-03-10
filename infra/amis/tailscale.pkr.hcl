packer {
  required_version = ">= 1.10.0"

  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "amazon-ami" "latest-ubuntu" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-mantic-*-arm64-server-*"
    root-device-type    = "ebs"
  }
  owners      = ["099720109477"]
  most_recent = true
}

source "amazon-ebs" "tailscale" {
  region               = "us-west-2"
  profile              = "packer"
  source_ami           = data.amazon-ami.latest-ubuntu.id
  subnet_id            = "subnet-094aa23f1f145f81a"
  instance_type        = "t4g.small"
  ssh_username         = "ubuntu"
  ssh_interface        = "private_ip"
  security_group_ids = [
    "sg-0f33b9d9f0b048328", # packer-instance
    "sg-0fe92a5c593a480c2", # packer-fargate-ssh
    "sg-06315c442e768445b", # tailscale-ssh-access
  ]
  imds_support         = "v2.0"
  encrypt_boot         = true
  ami_name             = "tailscale {{timestamp}}"
  iam_instance_profile = "tailscale"
  deprecate_at         = timeadd(timestamp(), "240h")
  ami_description      = "created from ${data.amazon-ami.latest-ubuntu.id}"
  run_tags = {
    Name = "tailscale {{timestamp}}"
  }
  snapshot_tags = {
    Name = "tailscale {{timestamp}}"
  }
}

build {
  sources = [
    "source.amazon-ebs.tailscale"
  ]

  provisioner "file" {
    source      = "tailscale_scripts"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline = ["sudo bash -xe /tmp/tailscale_scripts/setup.sh"]
  }

  provisioner "shell" {
    inline = ["sudo rm -rf /tmp/*"]
  }

  post-processor "manifest" {
    output     = "output/tailscale_manifest.json"
    strip_path = true
  }
}
