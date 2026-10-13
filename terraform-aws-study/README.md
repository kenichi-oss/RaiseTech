## 事前準備:tfstate 保存用 S3 バケットの作成

本構成は、tfstate を S3 バックエンドに保存します。
**`envs/development` で `terraform init` する前に、`backend-setup` を先に apply して、バケットを作成してください。**
(バケットが存在しないと、`init` が失敗します。)

### 手順

1. バケットを作成する(`backend-setup`)

   cd backend-setup
   terraform init
   terraform plan
   terraform apply

   apply が終わったら、**必ず手順2(バケット名の確認と書き換え)に進んでください。**

### 2. バケット名を確認し、必要なら書き換える

> ⚠️ **注意(別の AWS アカウントで実行する場合は必須)**
> `envs/development/terraform.tf` の `bucket` には、私のアカウント ID を含むバケット名を**固定で記載**しています
> (backend ブロックには変数を使えないため)。
> **別のアカウントでは、このままだと `terraform init` が失敗します。必ず次の手順で書き換えてください。**

**① 作成されたバケット名を取得する**

```bash
cd backend-setup
terraform output -raw bucket_name
```

`tfstate-study-<AWS アカウント ID>` の形式で表示されます。

**② `envs/development/terraform.tf` の `bucket` を書き換える**

エディタで、`backend "s3"` の `bucket` を、①で表示された値に書き換えます。

```hcl
backend "s3" {
  bucket = "①で表示されたバケット名"
  ...
}
```

コマンドで書き換える場合(macOS)は、次のとおりです。

```bash
cd ..
BUCKET=$(cd backend-setup && terraform output -raw bucket_name)
sed -i '' "s|bucket *= *\".*\"|bucket       = \"${BUCKET}\"|" envs/development/terraform.tf
grep -n "bucket" envs/development/terraform.tf    # 書き換わったか確認
```

Linux の場合は、`sed -i '' ...` を `sed -i ...` にしてください。

**③ 同じ AWS アカウントで実行する場合**

`terraform output` の値が、すでに `terraform.tf` の値と同じなら、書き換えは不要です。

2. 環境を構築する(`envs/development`)

   cd ../envs/development
   terraform init
   terraform plan
   terraform apply

### 別の AWS アカウントで実行する場合

`backend` ブロックには変数を使えないため、`envs/development/terraform.tf` の `bucket` に
バケット名を直接記載しています。別のアカウントで実行する場合は、手順1の後に
`terraform output bucket_name` で表示された値に、`bucket` を書き換えてください。

### 削除するときの順番

`envs/development` を先に `terraform destroy` し、その後に `backend-setup` を destroy します。
先にバケットを消すと、tfstate が失われます。バケットに中身が残っている場合は、先に空にしてください。

### AWS 認証

`provider.tf` で、AWS プロファイル `study` を指定しています。
`aws configure --profile study` などで、事前に同名のプロファイルを作成してください。
別の名前を使う場合は、`provider.tf` の `profile` を書き換えてください。

### モジュールの構成

modules: https://github.com/kenichi-oss/RaiseTech/tree/feature/terraform-migration/terraform-aws-study/modules
セキュリティグループの定義: https://github.com/kenichi-oss/RaiseTech/blob/feature/terraform-migration/terraform-aws-study/modules/security_group/main.tf
envs から modules を呼び出している箇所: https://github.com/kenichi-oss/RaiseTech/blob/feature/terraform-migration/terraform-aws-study/envs/development/main.tf
