terraform {
  required_version = ">= 0.14.9"

  backend "s3" {
    bucket         = "st-tfstate-default"
    region         = "ap-northeast-1"
    key            = "my-eks-cluster/clusters/develop/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "TFStateLock"
  }
}

module "eks" {
  source = "../../modules/eks"

  create                                = true
  cluster_name                          = "MyFirstCluster"
  cluster_additional_security_group_ids = []
  cluster_endpoint_public_access_cidrs  = ["0.0.0.0/0"]

  eks_managed_node_group_defaults = {
    # reference: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/modules/eks-managed-node-group/variables.tf#L242
    disk_size     = 20 # default value
    max_size      = 3  # default value
    capacity_type = "SPOT"
  }

  eks_managed_node_groups = {
    spot = {
      instance_types = ["r5.large", "r5n.large", "r4.large"]
      capacity_type  = "SPOT"
      max_size       = 3
      min_size       = 1
      desired_size   = 1
    }
  }

  vpc_azs             = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  vpc_cidr            = "10.0.0.0/16"
  vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  vpc_public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}
