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
}
