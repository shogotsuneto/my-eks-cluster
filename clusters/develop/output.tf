output "create" {
  value = var.create ? "true" : "false"
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "aws_auth_configmap" {
  value = module.eks.aws_auth_configmap
}
