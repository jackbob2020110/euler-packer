# packer-linux

**packer for rockyLinux93**

```
packer init vmware-rocky93.pkr.hcl
packer build vmware-rocky93.pkr.hcl
```


**packer for OpenEuler 22.03**

packer init vmware-OpenEuler.pkr.hcl
packer build vmware-OpenEuler.pkr.hcl


### Usage

This virtual machine template must be builded using Packer.

- ``cd packer-rockylinux9``
- ``packer init vmware-iso-rockylinux9.pkr.hcl``
- ``packer build vmware-iso-rockylinux9.pkr.hcl``

This template uses the **root** user with the password **vagrant**.
