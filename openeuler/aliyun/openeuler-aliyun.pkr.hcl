packer {
  required_plugins {
    alicloud = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/alicloud"
    }
  }
}

variables {
  version = env("OPENEULER_VERSION")
  arch = env("OPENEULER_ARCH")
  source_image = env("SOURCE_IMAGE_ID")
  vpc_id = env("VPC_ID")
  subnet_id = env("SUBNET_ID")
  current_time = env("CURRENT_TIME")
}

source "alicloud-ecs" "test" {
  image_name           = "packer_basic"
  source_image         = "centos_7_03_64_20G_alibase_20170818.vhd"
  ssh_username         = "root"
  instance_type        = "ecs.t5-lc1m1.small"
  internet_charge_type = "PayByTraffic"
  io_optimized         = "true"
}

build {
  sources = ["source.alicloud-ecs.test"]

  provisioner "shell" {
    inline = [
      "sleep 30",
      "yum install redis.x86_64 -y"
    ]
  }
  post-processor "manifest" {
    output = "alicloud-manifest.json"
  }
}