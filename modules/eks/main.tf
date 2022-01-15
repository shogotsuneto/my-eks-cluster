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

locals {
  region       = "ap-northeast-1"
  cluster_name = var.cluster_name
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  create                                = var.create
  cluster_name                          = local.cluster_name
  cluster_additional_security_group_ids = var.cluster_additional_security_group_ids
  cluster_endpoint_private_access       = false # default
  cluster_endpoint_public_access        = true  # default
  cluster_endpoint_public_access_cidrs  = var.cluster_endpoint_public_access_cidrs

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["r5.large", "r5n.large", "r4.large"]
    capacity_type  = "SPOT"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway = var.create

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }
}
