variable "vm_image" {
  description = "VM image to use (e.g., Ubuntu cloud image)."
  type        = string
  default     = "ubuntu-22.04"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM instance."
  type        = string
  default     = "Standard_B1s"
}

variable "vm_admin_username" {
  description = "Admin username for VM login"
  type        = string
  default     = "bgpuser"
}

variable "vm_admin_password" {
  description = "Admin password for VM login. Must meet Azure complexity requirements."
  type        = string
  sensitive   = true
}

variable "location" {
  description = "The azure region to use"
  type        = string
  default     = "uksouth"
}

variable "vnets" {
  description = "Virtual networks configuration"
  type = map(object({
    vnet_name             = string
    address_space         = list(string)
    primary_subnet_name   = string
    primary_subnet_prefix = list(string)
    create_bastion_subnet = bool
    bastion_subnet_prefix = optional(list(string), [])
  }))
  default = {
    vnet1 = {
      vnet_name             = "bgp-vnet1"
      address_space         = ["10.1.0.0/24"]
      primary_subnet_name   = "subnet1"
      primary_subnet_prefix = ["10.1.0.0/27"]
      create_bastion_subnet = true
      bastion_subnet_prefix = ["10.1.0.32/27"]
    }
    vnet2 = {
      vnet_name             = "bgp-vnet2"
      address_space         = ["10.2.0.0/24"]
      primary_subnet_name   = "subnet2"
      primary_subnet_prefix = ["10.2.0.0/27"]
      create_bastion_subnet = false
    }
    vnet3 = {
      vnet_name             = "bgp-vnet3"
      address_space         = ["10.3.0.0/24"]
      primary_subnet_name   = "subnet3"
      primary_subnet_prefix = ["10.3.0.0/27"]
      create_bastion_subnet = false
    }
  }
}

variable "vnet_peerings" {
  description = "VNet peering configuration"
  type = map(object({
    name          = string
    source_vnet   = string
    target_vnet   = string
  }))
  default = {
    vnet1_to_vnet2 = {
      name        = "vnet1-to-vnet2"
      source_vnet = "vnet1"
      target_vnet = "vnet2"
    }
    vnet2_to_vnet1 = {
      name        = "vnet2-to-vnet1"
      source_vnet = "vnet2"
      target_vnet = "vnet1"
    }
    vnet1_to_vnet3 = {
      name        = "vnet1-to-vnet3"
      source_vnet = "vnet1"
      target_vnet = "vnet3"
    }
    vnet3_to_vnet1 = {
      name        = "vnet3-to-vnet1"
      source_vnet = "vnet3"
      target_vnet = "vnet1"
    }
    vnet2_to_vnet3 = {
      name        = "vnet2-to-vnet3"
      source_vnet = "vnet2"
      target_vnet = "vnet3"
    }
    vnet3_to_vnet2 = {
      name        = "vnet3-to-vnet2"
      source_vnet = "vnet3"
      target_vnet = "vnet2"
    }
  }
}

variable "vms" {
  description = "Virtual machines configuration"
  type = map(object({
    vm_name   = string
    nic_name  = string
    vm_size   = string
    vnet_key  = string
  }))
  default = {
    vm1 = {
      vm_name  = "bgp-vm1"
      nic_name = "bgp-nic1"
      vm_size  = "Standard_B1s"
      vnet_key = "vnet1"
    }
    vm2 = {
      vm_name  = "bgp-vm2"
      nic_name = "bgp-nic2"
      vm_size  = "Standard_B1s"
      vnet_key = "vnet2"
    }
    vm3 = {
      vm_name  = "bgp-vm3"
      nic_name = "bgp-nic3"
      vm_size  = "Standard_B1s"
      vnet_key = "vnet3"
    }
  }
}
