terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = local.region
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region = "ap-northeast-1"

  // variables shared among modules
  cluster_name        = var.cluster_name
  create              = var.create
  public_subnets_only = var.public_subnets_only
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  create                                = local.create
  cluster_name                          = local.cluster_name
  cluster_additional_security_group_ids = var.cluster_additional_security_group_ids
  cluster_endpoint_private_access       = false # default
  cluster_endpoint_public_access        = true  # default
  cluster_endpoint_public_access_cidrs  = var.cluster_endpoint_public_access_cidrs

  vpc_id     = module.vpc.vpc_id
  subnet_ids = local.public_subnets_only ? module.vpc.public_subnets : module.vpc.private_subnets

  eks_managed_node_group_defaults = merge({
    create_iam_role = !var.create_node_iam_role # create here, not in the node group module
    iam_role_arn    = var.create && var.create_node_iam_role ? aws_iam_role.node[0].arn : null
  }, var.eks_managed_node_group_defaults)
  eks_managed_node_groups = var.eks_managed_node_groups
}

module "vpc" {
  # https://github.com/terraform-aws-modules/terraform-aws-vpc
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = local.create && !local.public_subnets_only
  single_nat_gateway = var.vpc_single_nat_gateway

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }
}

################################################################################
# IAM Role for eks node instances
################################################################################
# copied and modified: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/modules/eks-managed-node-group/main.tf#L390

locals {
  iam_role_name = "${local.cluster_name}-eks-node-group"

  iam_role_policy_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  cni_policy = "${local.iam_role_policy_prefix}/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = var.create && var.create_node_iam_role ? 1 : 0

  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "node" {
  count = var.create && var.create_node_iam_role ? 1 : 0

  name        = local.iam_role_name
  name_prefix = null
  path        = var.node_iam_role_path
  description = var.node_iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.node_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.node_iam_role_tags)
}

# Policies attached ref https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_iam_role_policy_attachment" "node" {
  for_each = var.create && var.create_node_iam_role ? toset(compact(distinct(concat([
    "${local.iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy",
    "${local.iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly",
    local.cni_policy,
  ], var.node_iam_role_additional_policies)))) : toset([])

  policy_arn = each.value
  role       = aws_iam_role.node[0].name
}
