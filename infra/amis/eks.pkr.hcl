packer {
  required_version = ">= 1.10.0"

  required_plugins {
    amazon = {
      version = ">= 1.3.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "amazon-parameterstore" "eks-ami" {
  name = "/aws/service/eks/optimized-ami/1.29/amazon-linux-2023/arm64/standard/recommended/image_id"
  with_decryption = false
}

source "amazon-ebs" "eks-node" {
  region     = "us-west-2"
  profile    = "packer"
  source_ami = data.amazon-parameterstore.eks-ami.value
  subnet_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
    most_free = true
    random    = false
  }
  instance_type               = "t4g.small"
  ssh_username                = "ec2-user"
  ssh_interface               = "private_ip"
  temporary_key_pair_name     = "eks {{timestamp}}"
  temporary_key_pair_type     = "ed25519"
  associate_public_ip_address = false
  security_group_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
  }
  imds_support         = "v2.0"
  encrypt_boot         = true
  ami_name             = "eks-node {{timestamp}}"
  iam_instance_profile = "eks-node"
  deprecate_at         = timeadd(timestamp(), "240h")
  ami_description      = "created from ${data.amazon-parameterstore.eks-ami.value}"
  run_tags = {
    Name = "packer building: eks-node {{timestamp}}"
  }
  snapshot_tags = {
    Name = "eks-node {{timestamp}}"
  }
}

build {
  sources = [
    "source.amazon-ebs.eks-node"
  ]

  provisioner "file" {
    source      = "shared"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "eks_scripts"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline = ["sudo bash -xe /tmp/eks_scripts/setup.sh"]
  }

  provisioner "shell" {
    inline = ["sudo rm -rf /tmp/*"]
  }

  post-processor "manifest" {
    output     = "output/eks_manifest.json"
    strip_path = true
  }
}