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

variable "vm_admin_password" {
  description = "Admin password for VM login. Must meet Azure complexity requirements."
  type        = string
  sensitive   = true
}

variable "onprem_router_count" {
  description = "Number of on-prem routers (VMs) to create."
  type        = number
  default     = 1
}

variable "location" {
  description = "The azure region to use"
  type = string
  default - "uksouth"
