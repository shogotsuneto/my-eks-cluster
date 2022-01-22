# kubeconfig 取得方法

IAM ロール／ユーザでアクセスする場合は `aws-auth` という configmap を編集する。
このリポジトリではシークレット DEVELOP_MAPUSERS_BASE64 から mapUsers を復元するなどして configmap を生成して apply している。

ユーザが追加されていれば、以下のコマンドで kubeconfig を設定できる。

```bash
aws --profile $PROFILE_NAME --region ap-northeast-1 eks update-kubeconfig --name $CLUSTER_NAME

# 確認
kubectl get node
```
