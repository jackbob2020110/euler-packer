packer {
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
    vagrant = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

source "vmware-vmx" "vmware" {
  source_path      = "F:\\vmware\\openeuler2203\\openeuler2203.vmx"
  communicator     = "ssh"
  ssh_username     = "vagrant"
  ssh_password     = "V@grant2024"
  shutdown_command = "sudo poweroff"
}

build {
  sources = ["source.vmware-vmx.vmware"]

  #provisioner "shell" {
   # script = "setup.sh"
  #}

  post-processor "vagrant" {
    compression_level = 9
    output              = "openeuler2203-packerfromVmware.box"
  }
}