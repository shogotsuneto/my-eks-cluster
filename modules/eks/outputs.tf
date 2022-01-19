output "cluster_id" {
  value = module.eks.cluster_id
}

output "node_iam_role_arn" {
  value = var.create && var.create_node_iam_role ? aws_iam_role.node[0].arn : null
}
