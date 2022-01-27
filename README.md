# My EKS Cluster

自分用あんちょこ（Cheat Sheet）的リポジトリ。
Monitoring / Service Mesh / GitOps などインフラ寄りの構成管理。

EKS クラスターのリソース管理には Terraform,
その他 k8s 内リソース管理には k8s manifests や helm charts などを利用。
GitHub Actions 上でインラインで生成等して apply しているものもそこそこある…

## Bootstrap 手順

- Terraform 用の Backend 作成
- デプロイ用の [IAM Role 作成](./docs/iam.md)
- GitHub Actions 用のシークレット作成（IAM ロール ARN、パーソナルアクセストークン、mapUsers）
- main に変更を PR&マージして GitHub Actions 起動
- [kubeconfig 取得](./docs/kubeconfig.md)
- ArgoCD のアプリケーション／プロジェクト作成
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
  - [Example (IRSA, Cluster Autoscaler, Instance Refresh)](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/complete)
  - [IAM Permissions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md)
- [Cluster Autoscaler](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/cluster-autoscaler.html)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- Istio
  - [Generate a manifest](https://istio.io/latest/docs/setup/install/istioctl/#generate-a-manifest-before-installation)
  - [Customize installation](https://istio.io/latest/docs/setup/additional-setup/customize-installation/)
  - [Alert Configuration](https://prometheus.io/docs/alerting/latest/configuration/)
- ArgoCD
  - [Get Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
  - [Declarative Setup](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/)
  - [App of Apps pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/)
- Flux 2
  - [Get Started](https://fluxcd.io/docs/get-started/)
  - [Terraform provider flux](https://github.com/fluxcd/terraform-provider-flux)
  - [Multi Tenancy](https://github.com/fluxcd/flux2-multi-tenancy)

### style and conventions

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
