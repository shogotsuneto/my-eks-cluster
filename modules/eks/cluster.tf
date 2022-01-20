module "eks" {
  source = "terraform-aws-modules/eks/aws"

  create                                = local.create
  cluster_name                          = local.cluster_name
  cluster_additional_security_group_ids = var.cluster_additional_security_group_ids
  cluster_endpoint_private_access       = false # default
  cluster_endpoint_public_access        = true  # default
  cluster_endpoint_public_access_cidrs  = var.cluster_endpoint_public_access_cidrs

  enable_irsa = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = local.public_subnets_only ? module.vpc.public_subnets : module.vpc.private_subnets

  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults
  eks_managed_node_groups         = var.eks_managed_node_groups
}
