packer {
  required_version = ">= 1.10.0"

  required_plugins {
    amazon = {
      version = ">= 1.3.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "amazon-ami" "latest-debian" {
  filters = {
    virtualization-type = "hvm"
    name                = "debian-12-arm64-*"
    root-device-type    = "ebs"
  }
  owners      = ["136693071363"]
  most_recent = true
}

source "amazon-ebs" "debian" {
  region     = "us-west-2"
  profile    = "packer"
  source_ami = data.amazon-ami.latest-debian.id
  subnet_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
    most_free = true
    random    = false
  }
  instance_type               = "t4g.small"
  ssh_username                = "admin"
  ssh_interface               = "private_ip"
  temporary_key_pair_name     = "debian {{timestamp}}"
  temporary_key_pair_type     = "ed25519"
  associate_public_ip_address = false
  security_group_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
  }
  imds_support         = "v2.0"
  encrypt_boot         = true
  ami_name             = "debian {{timestamp}}"
  iam_instance_profile = "server"
  deprecate_at         = timeadd(timestamp(), "240h")
  ami_description      = "created from ${data.amazon-ami.latest-debian.id}"
  # run_tags = {
  #   Name = "packer/debian/{{timestamp}}"
  # }
  # snapshot_tags = {
  #   Name = "packer/debian/{{timestamp}}"
  # }
}

build {
  sources = [
    "source.amazon-ebs.debian"
  ]

  provisioner "file" {
    source      = "shared"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "debian_scripts"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline = ["sudo bash -xe /tmp/debian_scripts/setup.sh"]
  }

  provisioner "shell" {
    inline = ["sudo rm -rf /tmp/*"]
  }

  post-processor "manifest" {
    output     = "output/debian_manifest.json"
    strip_path = true
  }
}
