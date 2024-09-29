packer {
  required_plugins {
    vmware = {
      source  = "github.com/hashicorp/vmware"
      version = "~> 1"
    }
  }
}

variable "box_basename" {
  type    = string
  default = "ubuntu-22.04"
}

variable "build_directory" {
  type    = string
  default = "./builds"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "102400"
}

variable "git_revision" {
  type    = string
  default = "__unknown_git_revision__"
}

variable "guest_additions_url" {
  type    = string
  default = ""
}

variable "headless" {
  type    = string
  default = "false"
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb"
}

variable "iso_name" {
  type    = string
  default = "d:\\iso\\ubuntu-22.04.1-live-server-amd64.iso"
}

variable "memory" {
  type    = string
  default = "1024"
}

variable "mirror" {
  type    = string
  default = "http://releases.ubuntu.com"
}

variable "mirror_directory" {
  type    = string
  default = "jammy"
}

variable "name" {
  type    = string
  default = "ubuntu-22.04"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "qemu_display" {
  type    = string
  default = "none"
}

variable "template" {
  type    = string
  default = "ubuntu-22.04-amd64"
}

variable "version" {
  type    = string
  default = "TIMESTAMP"
}
# The "legacy_isotime" function has been provided for backwards compatability, but we recommend switching to the timestamp and formatdate functions.

locals {
  build_timestamp = "${legacy_isotime("20060102150405")}"
  http_directory  = "${path.root}/http"
}

source "vmware-iso" "linux-ubuntu-server" {
  boot_command     = [
      "c<wait5>",
      "<wait5>linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
      "<enter><wait>",
      "initrd /casper/initrd<enter><wait>",
      "boot<enter>"
  ]
  boot_wait        = "5s"
  cpus             = "${var.cpus}"
  disk_size        = "${var.disk_size}"
  disk_adapter_type = "scsi"
  disk_type_id      = "0"
  guest_os_type    = "ubuntu-64"
  headless         = "${var.headless}"
  http_directory   = "${local.http_directory}"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_name}"
  memory           = "${var.memory}"
  output_directory = "${var.build_directory}/packer-${var.template}-vmware"
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_timeout      = "30m"
  ssh_username     = "vagrant"
  vm_name          = "${var.template}"
  vmx_data = {
    "cpuid.coresPerSocket"    = "1"
    "ethernet0.pciSlotNumber" = "32"
  }
  vmx_remove_ethernet_interfaces = true
}

build {
  sources = ["source.vmware-iso.linux-ubuntu-server"]

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/vagrant", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts-u/update.sh", 
    "${path.root}/scripts-u/motd.sh", 
    "${path.root}/scripts-u/sshd.sh", 
    "${path.root}/scripts-u/networking.sh", 
    "${path.root}/scripts-u/sudoers.sh", 
    "${path.root}/scripts-u/vagrant.sh", 
    "${path.root}/scripts-u/vmware.sh", 
    "${path.root}/scripts-u/hyperv.sh", 
    "${path.root}/scripts-u/cleanup.sh", 
    "${path.root}/scripts-u/minimize.sh"]
  }

  post-processor "vagrant" {
    output = "${var.build_directory}/${var.box_basename}.{{ .Provider }}.box"
  }
}
