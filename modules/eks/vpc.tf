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
