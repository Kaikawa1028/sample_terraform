# sample-project-infrastructure
サンプルプロジェクトのインフラリソースです

## 環境
- Terraform 0.12.19
- aws 2.45.0

## インフラ構成
![インフラ構成](https://gyazo.com/15a06a7d37fb3f56983f9a58d1ae7554.png)

## 初期構築
1. keypairの作成
    - https://kenzo0107.hatenablog.com/entry/2017/03/27/215941
    - ec2.tfのaws_key_pairに鍵情報を入力する。
2. s3にバケットを作成
3. route53にホストゾーンを作成※ドメインを取得していな場合はお名前.comなどで取得
    - output.tfのzone_idを修正する。
4. https://www.evernote.com/l/Acwsq4ST6SNFIawBZNcSYARr8SnMYTRJKI0 に沿って起動する。

## 環境構築

```
terraform init \
  -backend=true \
  -backend-config="bucket=sample-project.terraform" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="region=ap-northeast-1"
```

```
cd ./development
terraform init \
  -backend=true \
  -backend-config="bucket=sample-project.terraform" \
  -backend-config="key=development.terraform.tfstate" \
  -backend-config="region=ap-northeast-1"
```

```
cd ../staging
terraform init \
  -backend=true \
  -backend-config="bucket=sample-project.terraform" \
  -backend-config="key=staging.terraform.tfstate" \
  -backend-config="region=ap-northeast-1"
```

```
cd ../production
terraform init \
  -backend=true \
  -backend-config="bucket=sample-project.terraform" \
  -backend-config="key=production.terraform.tfstate" \
  -backend-config="region=ap-northeast-1"
```

```
cd ../
```
