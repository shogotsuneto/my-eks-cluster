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
  region = "ap-northeast-1"

  // variables shared among modules
  cluster_name        = var.cluster_name
  create              = var.create
  public_subnets_only = var.public_subnets_only

  tags = {
    ClusterName = local.cluster_name
  }
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "cluster" {
  name = var.create ? module.eks.cluster_id : "dummy"
}
