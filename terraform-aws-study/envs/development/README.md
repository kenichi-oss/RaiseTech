***
**今回の構成。
***
中級編で作成した CloudFormation のスタックを、Terraform へ移行。

```
terraform-aws-study/
├── backend-setup/   # tfstate 保存用のバックエンド S3 へ保存。
├── modules/    # vpc, security_group, iam, rds, ec2, alb, waf, moitoring
└── envs/
    └── development/ # 環境ごとの設定
```
***
**実施日 2026.10.12
***

***
**Terraform apply の結果
***
![apply画像](<images/apply.png>)

***
**アプリの動作確認
***
alb_dns_name = "my-app-alb-367420437.ap-northeast-1.elb.amazonaws.com"
![アプリ起動画像](<images/myapp.png>)

***
**terraform state list  # リソース一覧を出力
**
![terraformで実行されているリソース一覧](<images/resource.png>)

***
**terraform.tfvars` に、次の値を設定します(Git 管理外)。
***

project_name 
region 
env  
vpc_cidr 
public_subnet_cidrs 
private_subnet_cidrs 
instance_type 
db_password 
notification_email 

***
**苦労した点、学んだ点
***
# .gitignore に Github 上に表示させないファイルを指定できることや、backend-setup で、S3 バゲットに tfstate ファイルを格納して、構成を考えていく必要があるという点について学びました。
# また、本環境の modules　は、他の環境を作成する際に、再利用できるように構成を考えることが大事という点についても学びました。
# 苦労した点については、development の main.tf,variables.tf と、modules の main.tf,variables.tf の設定すべき値を、どこに設定する必要があるのか、については、理解するのに時間がかかりました。AI とメンターの方と壁打ちしながら、それぞれのファイルの役割みたいなものを理解して行きました。

# 自分メモ
# development 環境

学習用の開発環境。

## modules は、再利用性があることが大事　（他の環境を作成しようとした時に使い回しできる）

## 実行方法

terraform init
terraform plan
terraform apply
