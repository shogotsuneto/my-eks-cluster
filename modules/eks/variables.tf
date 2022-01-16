variable "create" {
  type    = bool
  default = true
}
variable "cluster_name" {
  type = string
}

variable "cluster_additional_security_group_ids" {
  type    = list(string)
  default = []
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "eks_managed_node_group_defaults" {
  type    = any
  default = {}
}

variable "eks_managed_node_groups" {
  type    = any
  default = {}
}
