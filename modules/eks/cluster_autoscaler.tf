#################################
# in cluster resources (helm release) should be
#      created OUTSIDE terraform to keep terraform configurations simple
# below resource section left tentatively as comments for reference purpose
#################################
# resource "helm_release" "cluster_autoscaler" {
#   name       = "cluster-autoscaler"
#   namespace  = "kube-system"
#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   version    = "9.11.0"

#   create_namespace = false

#   set {
#     name  = "awsRegion"
#     value = local.region
#   }

#   set {
#     name  = "rbac.serviceAccount.name"
#     value = "cluster-autoscaler-aws"
#   }


#   set {
#     name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = module.iam_assumable_role_cluster_autoscaler.iam_role_arn
#     type  = "string"
#   }

#   set {
#     name  = "autoDiscovery.clusterName"
#     value = local.cluster_name
#   }

#   set {
#     name  = "autoDiscovery.enabled"
#     value = "true"
#   }

#   set {
#     name  = "rbac.create"
#     value = "true"
#   }

#   depends_on = [
#     module.eks.cluster_id,
#   ]
# }

locals {
  autoscaler_sa_name = "cluster-autoscaler-aws"
}

module "iam_assumable_role_cluster_autoscaler" {
  # https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-assumable-role-with-oidc
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role      = var.create
  role_name_prefix = "cluster-autoscaler"
  role_description = "IRSA role for cluster autoscaler"

  provider_url                   = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns               = var.create ? [aws_iam_policy.cluster_autoscaler[0].arn] : []
  oidc_fully_qualified_subjects  = ["system:serviceaccount:kube-system:${local.autoscaler_sa_name}"]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

  tags = local.tags
}

resource "aws_iam_policy" "cluster_autoscaler" {
  count = var.create ? 1 : 0

  name   = "${local.cluster_name}-ClusterAutoscalerPolicy"
  policy = data.aws_iam_policy_document.cluster_autoscaler.json

  tags = local.tags
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid = "clusterAutoscalerAll"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
    ]
    resources = ["*"]
  }

  statement {
    sid = "clusterAutoscalerOwn"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}
