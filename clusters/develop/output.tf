output "create" {
  value = var.create ? "true" : "false"
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "aws_auth_configmap" {
  value = module.eks.aws_auth_configmap
}

output "autoscaler_role_arn" {
  value = module.eks.autoscaler_role_arn
}

output "autoscaler_sa_name" {
  value = module.eks.autoscaler_sa_name
}

output "alertmanager_role_arn" {
  value = module.eks.alertmanager_role_arn
}
