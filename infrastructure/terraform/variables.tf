variable "location" {
  description = "Région Azure"
  type        = string
  default     = "francecentral"
}

variable "resource_group_name" {
  description = "Nom du groupe de ressources"
  type        = string
  default     = "rg-iam360"
}

variable "aks_name" {
  description = "Nom du cluster AKS"
  type        = string
  default     = "aks-iam360"
}

variable "midpoint_replicas" {
  description = "Nombre de pods MidPoint"
  type        = number
  default     = 3
}