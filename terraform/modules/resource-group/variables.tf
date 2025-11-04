variable "name" {
  description = "Nombre del Resource Group"
  type        = string
}

variable "location" {
  description = "Región de Azure donde se creará el Resource Group"
  type        = string
}

variable "tags" {
  description = "Tags adicionales para el Resource Group"
  type        = map(string)
  default     = {}
}
