// Description : Creating a virtual machine template under Rocky Linux 9 from ISO file with Packer using VMware Workstation
// Author : Yoann LAMY <https://github.com/ynlamy/packer-rockylinux9>
// Licence : GPLv3

// Packer : https://www.packer.io/

packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

variable "iso" {
  type        = string
  description = "A URL to the ISO file"
  default     = "D:\\iso\\openEuler-22.03-LTS-SP4-x86_64-dvd.iso"
}

variable "checksum" {
  type        = string
  description = "The checksum for the ISO file"
  default     = "sha256:C5D9069518444DA9D402D38910B8634A6EBC1CAC63E899DD54A04B3EEC1C76E8"
}

variable "headless" {
  type        = bool
  description = "When this value is set to true, the machine will start without a console"
  default     = false
}

variable "name" {
  type        = string
  description = "This is the name of the new virtual machine"
  default     = "vm-openEuler"
}

variable "username" {
  type        = string
  description = "The username to connect to SSH"
  default     = "root"
}

variable "password" {
  type        = string
  description = "A plaintext password to authenticate with SSH"
  default     = "vagrant"
}

variable "vmware_network_adapter_type" {
  type    = string
  default = "e1000e"
}

variable "box_basename" {
  type        = string
  description = "The base name of the output box file"
  default     = "openEuler-22.03-LTS-SP4-x86_64-vmware"
}

variable "build_directory" {
  type        = string
  description = "The directory where the box file will be built"
  default     = "./builds"
}


source "vmware-iso" "openEuler" {
  // Documentation : https://developer.hashicorp.com/packer/integrations/hashicorp/vmware/latest/components/builder/iso

  // ISO configuration
  iso_url      = var.iso
  iso_checksum = var.checksum

  // Driver configuration
  cleanup_remote_cache = false
  
  // Hardware configuration
  vm_name           = var.name
  vmdk_name         = var.name
  version           = "21"
  guest_os_type     = "centos-64"
  cpus              = 2
  memory            = 2048
  disk_size         = 102400
  disk_adapter_type = "scsi"
  disk_type_id      = "0"
  network           = "nat"
  network_adapter_type = "e1000e"
  sound             = false
  usb               = false

  // Run configuration
  headless = var.headless

  // Shutdown configuration
  shutdown_command = "systemctl poweroff"

  // Http directory configuration
  http_directory = "http"


  // Communicator configuration
  communicator = "ssh"
  ssh_username = var.username
  ssh_password = var.password
  ssh_timeout  = "30m"

  // Output configuration
  output_directory = "template"

  // Boot configuration
  boot_command = ["<wait><tab> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks_openEuler.cfg<enter>"]
  boot_wait    = "10s"
  // Export configuration
  #format          = "vmx"
  skip_compaction = false

  vmx_remove_ethernet_interfaces = true
}

build {
  sources = ["source.vmware-iso.openEuler"]

  provisioner "shell" {
    scripts = [
      "scripts/provisioning.sh",
      "scripts/vagrant.sh",
      "scripts/vmware.sh",
      "scripts/minimize.sh",
     ]
  }

  post-processor "vagrant" {
    compression_level = 9
    output              = "${var.build_directory}/${var.box_basename}.box"
  }

}
