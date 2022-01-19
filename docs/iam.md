# IAM

## パイプライン用の IAM ロール

クラスタ Bootstrap 用。
依存先が複数あるのでとりあえずは手動作成で。

### spec

- EKS クラスターに関連するリソースを作成できる
  - 別に作成済みのポリシーをアタッチ
- Terraform バックエンドの S3 や DynamoDB へアクセスできる
  - 別に作成済みのポリシーをアタッチ
- github actions から web トークン assume role できる
  - 作成済みの Identity Provider を許可

### trust relationships のテンプレート

Principal に IAM Group を指定できないようなので、Bootstrap 作業をする人を直接指定するしかなさそう。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS::AccountId}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${RepoOwner}/${RepoName}:*"
        }
      }
    }
  ]
}
```

## kubeconfig 取得方法

IAM ロール／ユーザでアクセスする場合は `aws-auth` という configmap を編集する。
このリポジトリではシークレット DEVELOP_MAPUSERS_BASE64 から mapUsers を復元するなどして configmap を生成して apply している。

ユーザが追加されていれば、以下のコマンドで kubeconfig を設定できる。

```bash
aws --profile $PROFILE_NAME --region ap-northeast-1 eks update-kubeconfig --name $CLUSTER_NAME

# 確認
kubectl get node
```
