# My Cluster Bootstrap

コントロールプレーン寄りの構成管理。

## TODO

- EKS クラスター
  - vpc,subnet など
  - Spot インスタンス利用
- Prometheus/Grafana
- Metric Server
- Istio
- データプレーン用の一部リソース（namespace や RBAC 周りなど）
- Flux2 や ArgoCD
- 上記を 1 コマンドで apply するスクリプトもしくはパイプライン
- データプレーン用の Git リポジトリ&アプリケーション

## References

### building blocks

- [Terraform Get Started - AWS](https://learn.hashicorp.com/collections/terraform/aws-get-started)
- [Terraform s3 Backend](https://www.terraform.io/language/settings/backends/s3)
- [Automate Terraform with GitHub Actions](https://learn.hashicorp.com/tutorials/terraform/github-actions)
- [AWS EKS Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
  - [Example (Complete)](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/complete)
  - [IAM Permissions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- Istio
  - [Generate a manifest](https://istio.io/latest/docs/setup/install/istioctl/#generate-a-manifest-before-installation)
  - [customize installation](https://istio.io/latest/docs/setup/additional-setup/customize-installation/)

### style and conventions

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
