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

resource "aws_iam_policy" "alertmanager_publishable" {
  name   = "${local.cluster_name}-alertmanager-publishable-policy"
  policy = data.aws_iam_policy_document.alertmanager_publishable.json

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
