# rbies-event-organizer-infrastructure
rbies 案件 event-organizer のインフラリソースです

## 環境
- Terraform 0.12.19
- aws 2.45.0

## 環境構築

```
terraform init \
  -backend=true \
  -backend-config="bucket=event-organizer.terraform" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="region=ap-northeast-1"
```

```
cd ./development
terraform init \
  -backend=true \
  -backend-config="bucket=event-organizer-terraform" \
  -backend-config="key=development.terraform.tfstate" \
  -backend-config="region=ap-northeast-1"
```

```
cd ../staging
terraform init \
  -backend=true \
  -backend-config="bucket=event-organizer-terraform" \
  -backend-config="key=staging.terraform.tfstate" \
  -backend-config="region=ap-northeast-1"
```

```
cd ../production
terraform init \
  -backend=true \
  -backend-config="bucket=event-organizer-terraform" \
  -backend-config="key=production.terraform.tfstate" \
  -backend-config="region=ap-northeast-1"
```

```
cd ../
```