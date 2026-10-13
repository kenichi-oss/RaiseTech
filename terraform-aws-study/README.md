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

2. バケット名が一致していることを確認する

   - `backend-setup` が作成するバケット名: `tfstate-study-<AWS アカウント ID>`
     (`bucket_prefix` の既定値 `tfstate-study` + アカウント ID)
   - `envs/development/terraform.tf` の `backend "s3"` の `bucket` が、上記と同じであること
   - `terraform output bucket_name` で、作成されたバケット名を確認できます

3. 環境を構築する(`envs/development`)

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
