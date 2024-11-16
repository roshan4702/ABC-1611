variable "location" {
  description = "The Azure region to create resources in."
  type        = string
  default     = "East US"
}

variable "rg_name" {
  description = "The name of the resource group."
  type        = string
  default     = "roshan_rg_exam"
}

variable "vnet_name_1" {
  description = "The name of the first virtual network (vnet1)."
  type        = string
  default     = "Rvnet1"
}

variable "vnet_name_2" {
  description = "The name of the second virtual network (vnet2)."
  type        = string
  default     = "Rvnet2"
}

variable "address_space_1" {
  description = "The address space for the first virtual network (vnet1)."
  type        = list(string)
  default     = ["10.0.5.0/16"]
}

variable "address_space_2" {
  description = "The address space for the second virtual network (vnet2)."
  type        = list(string)
  default     = ["10.15.0.0/16"]
}

variable "admin_username" {
  description = "The administrator username for the virtual machines."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "The administrator password for the virtual machines."
  type        = string
  sensitive   = true
}

# Optional: VM size (can be customized as per requirement)
variable "vm_size" {
  description = "The size of the virtual machines."
  type        = string
  default     = "Standard_B1s"
}

