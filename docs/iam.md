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
