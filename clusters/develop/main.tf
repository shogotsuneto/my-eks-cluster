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

  instance_name = "ModularizedInstance"
}
