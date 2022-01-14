# EKS Cluster

## 手動手順

1. プロジェクトルートで `cp .env.example .env` し値を書き入れる

2. docker を立ち上げる

```sh
docker-compose up -d
docker-compose exec terraform bash
```

3. このディレクトリに移動 `cd clusters/develop`

4. apply

```sh
# in the terraform container
terraform init
terraform plan
terraform apply
```

5. inspect

```sh
terraform show
terraform output
terraform console
```

6. destroy

```sh
terraform destroy
```
