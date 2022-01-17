# My EKS Cluster

自分用あんちょこ（Cheat Sheet）的リポジトリ。
コントロールプレーン寄りの構成管理。

EKS クラスターのリソース管理には Terraform,  
その他 k8s 内リソース管理には k8s manifest ファイルを利用（予定）。

## Bootstrap 手順

- Terraform 用の Backend 作成
- デプロイ用の [IAM Role 作成](./doc/IAM_role.md)
- GitHub Actions 用のシークレット作成（IAM ロール ARN、パーソナルアクセストークン）
- main に変更を PR&マージして GitHub Actions 起動（どうしてもというなら手元から terraform apply）
- [kubeconfig 取得](./doc/iam.md#kubeconfig-取得方法)
- 以下 WIP

## TODO

- EKS クラスター
  - vpc,subnet など
  - Spot インスタンス利用
- Prometheus/Grafana
- Metric Server
- Istio
- データプレーン用の k8s 内リソース（namespace や RBAC 周りなど）
- Flux2 や ArgoCD
- 上記を 1,2 ステップで apply するスクリプトもしくはパイプライン
- データプレーン用の永続化層（k8s 外の s3, RDS, KeySpaces など）
- データプレーン用の Git リポジトリ&アプリケーション

## References

### building blocks

- [considered] [Terraform Get Started - AWS](https://learn.hashicorp.com/collections/terraform/aws-get-started)
- [considered] [Terraform s3 Backend](https://www.terraform.io/language/settings/backends/s3)
- [considered] [Automate Terraform with GitHub Actions](https://learn.hashicorp.com/tutorials/terraform/github-actions)
- [AWS EKS Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
  - [Example (Complete)](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/complete)
  - [IAM Permissions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- Istio
  - [Generate a manifest](https://istio.io/latest/docs/setup/install/istioctl/#generate-a-manifest-before-installation)
  - [customize installation](https://istio.io/latest/docs/setup/additional-setup/customize-installation/)
- ArgoCD
  - [Get Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
  - [Declarative Setup](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/)
- Flux 2
  - [Get Started](https://fluxcd.io/docs/get-started/)
  - [Terraform provider flux](https://github.com/fluxcd/terraform-provider-flux)
  - [Multi Tenancy](https://github.com/fluxcd/flux2-multi-tenancy)

### style and conventions

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
