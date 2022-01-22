output "cluster_id" {
  value = module.eks.cluster_id
}

output "aws_auth_configmap" {
  value = module.eks.aws_auth_configmap_yaml
}

output "autoscaler_role_arn" {
  value = module.iam_assumable_role_cluster_autoscaler.iam_role_arn
}

output "autoscaler_sa_name" {
  value = local.autoscaler_sa_name
}
