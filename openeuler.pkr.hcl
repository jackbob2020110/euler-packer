// Description : Creating a virtual machine template under Rocky Linux 9 from ISO file with Packer using VMware Workstation
// Author : Yoann LAMY <https://github.com/ynlamy/packer-openeuler>
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
  default     = "vm-openeuler"
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

source "vmware-iso" "openeuler" {
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
  cpus              = 1
  vmx_data = {
    "numvcpus" = "2"
  }
  memory            = 2048
  disk_size         = 102400
  disk_adapter_type = "scsi"
  disk_type_id      = "0"
  network           = "nat"
  network_adapter_type = "E1000"
  sound             = false
  usb               = false

  // Run configuration
  headless = var.headless

  // Shutdown configuration
  shutdown_command = "systemctl poweroff"

  // Http directory configuration
  http_directory = "http"

  // Boot configuration
  boot_command = ["<wait><tab> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/9ks.cfg<enter>"]
  boot_wait    = "10s"

  // Communicator configuration
  communicator = "ssh"
  ssh_username = var.username
  ssh_password = var.password
  ssh_timeout  = "30m"

  // Output configuration
  output_directory = "template"

  // Export configuration
  #format          = "vmx"
  skip_compaction = false
  vmx_remove_ethernet_interfaces = true
}

build {
  sources = ["source.vmware-iso.openeuler"]

  provisioner "shell" {
    scripts = [
      "scripts/vagrant.sh"
    ]
  }

  post-processor "vagrant" {
    keep_input_artifact = false
    output              = "openEuler-22.03-LTS-SP4-vmware-template.box"
  }

}
