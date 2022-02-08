locals {
  alertmanager_sa_name   = "alertmanager-sa"
  alertmanager_namespace = "monitoring"
}

module "iam_assumable_role_alertmanager" {
  # https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-assumable-role-with-oidc
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role      = var.create
  role_name_prefix = "${local.cluster_name}-alertmanager"
  role_description = "IRSA role for alertmanager"

  provider_url                   = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns               = var.create ? [aws_iam_policy.alertmanager_publishable.arn] : []
  oidc_fully_qualified_subjects  = ["system:serviceaccount:${local.alertmanager_namespace}:${local.alertmanager_sa_name}"]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

  tags = local.tags
}

resource "aws_iam_role" "alertmanager_publisher" {
  # To publish to Amazon SNS from the alertmanager using iam roles, you need two-step role assumption
  # 1. create session using the AWS SDK credential chain ("iam_assumable_role_alertmanager" role)
  # 2. assume the role for publishing (this "alertmanager_publisher" role)
  # see the implementation: https://github.com/prometheus/alertmanager/blob/main/notify/sns/sns.go#L98

  name               = "${local.cluster_name}_alertmanager_publisher"
  assume_role_policy = data.aws_iam_policy_document.alertmanager_publisher_assumable.json
  inline_policy {
    name   = "alertmanager_publisher_inline_policy"
    policy = data.aws_iam_policy_document.alertmanager_publishable.json
  }

  tags = local.tags
}

data "aws_iam_policy_document" "alertmanager_publishable" {
  statement {
    sid     = "alertmanagerPublish"
    actions = ["sns:Publish"]
    resources = [
      aws_sns_topic.alertmanager.arn
    ]
  }
}

data "aws_iam_policy_document" "alertmanager_publisher_assumable" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [module.iam_assumable_role_alertmanager.iam_role_arn]
    }
  }
}

resource "aws_iam_policy" "alertmanager_subscribable" {
  name   = "${local.cluster_name}-alertmanager-subscribable-policy"
  policy = data.aws_iam_policy_document.alertmanager_subscribable.json

  tags = local.tags
}

data "aws_iam_policy_document" "alertmanager_subscribable" {
  statement {
    sid     = "alertmanagerSubscribe"
    actions = ["sns:Subscribe"]
    resources = [
      aws_sns_topic.alertmanager.arn
    ]
  }
}

resource "aws_sns_topic" "alertmanager" {
  name = "${local.cluster_name}_alertmanager_topic"
}
