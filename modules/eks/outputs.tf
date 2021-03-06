locals {
  # values shared by multiple outputs
  alertmanager_publisher_role_arn = var.create ? aws_iam_role.alertmanager_publisher[0].arn : ""
  alertmanager_topic_arn          = aws_sns_topic.alertmanager.arn
}

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

output "alertmanager_role_arn" {
  value = module.iam_assumable_role_alertmanager.iam_role_arn
}

output "alertmanager_sa_name" {
  value = local.alertmanager_sa_name
}

output "alertmanager_publisher_role_arn" {
  value = local.alertmanager_publisher_role_arn
}

output "alertmanager_topic_arn" {
  value = local.alertmanager_topic_arn
}

output "alertmanager_yaml" {
  value = trimspace(templatefile(
    "${path.module}/templates/monitoring/alertmanager.tpl.yaml",
    {
      TOPIC_ARN = local.alertmanager_topic_arn
      ROLE_ARN  = local.alertmanager_publisher_role_arn
    }
  ))
}

output "map_roles" {
  # used aws_auth_configmap_yaml of the original eks module as reference:
  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/outputs.tf#L164
  value = join("\n", compact(flatten([
    [for group in module.eks_managed_node_group : trimspace(templatefile(
      "${path.module}/templates/mapRoles/eks_managed_node.tpl.yaml",
      { ROLE_ARN = group.iam_role_arn }
    ))],
    [for group in module.eks.fargate_profiles : trimspace(templatefile(
      "${path.module}/templates/mapRoles/fargate_profile.tpl.yaml",
      { ROLE_ARN = group.fargate_profile_arn }
    ))]
  ])))
}
