variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "primary_subnet_name" {
  description = "Name of the primary subnet"
  type        = string
}

variable "primary_subnet_prefix" {
  description = "Address prefix for primary subnet"
  type        = list(string)
}

variable "create_bastion_subnet" {
  description = "Whether to create a Bastion subnet"
  type        = bool
  default     = false
}

variable "bastion_subnet_prefix" {
  description = "Address prefix for Bastion subnet"
  type        = list(string)
  default     = []
}
