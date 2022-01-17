# IAM

## パイプライン用の IAM ロール

クラスタ Bootstrap 用。
依存先が多いのでとりあえずは手動作成で。

### spec

- EKS クラスターに関連するリソースを作成できる
  - 別に作成済みのポリシーをアタッチ
- Terraform バックエンドの S3 や DynamoDB へアクセスできる
  - 別に作成済みのポリシーをアタッチ
- github actions から web トークン assume role できる
  - 作成済みの Identity Provider を許可
- 特定の IAM ユーザから assume role できる（kubectl 初期接続用）

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
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${AWS::AccountId}:user/${IAMUserName}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## kubeconfig 取得方法

### Bootstrapper

```bash
aws --profile $PROFILE_NAME --region ap-northeast-1 eks update-kubeconfig --name $CLUSTER_NAME --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}

# 確認
kubectl get node
```

### 追加ユーザ

IAM ユーザ等でアクセスする場合は `aws-auth` という config map を編集する。

https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html

IAM グループは追加できなそうなのがネックだが、どこかでコード化して管理できれば  
client certificate を使うより便利そう？
