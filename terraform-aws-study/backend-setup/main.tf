
# 自分のAWSアカウントIDを取得(バケット名を一意にするため)
data "aws_caller_identity" "current" {}

locals {
  bucket_name = "${var.bucket_prefix}-${data.aws_caller_identity.current.account_id}"
}

# ① バケット本体
resource "aws_s3_bucket" "tfstate" {
  bucket = local.bucket_name
}

# ③ 暗号化(state には秘密情報が含まれることがある)
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ④ 公開ブロック(絶対に公開しない)
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 誤って terraform destroy しても消えないようにする安全装置
#  lifecycle {
#    prevent_destroy = true
#  }
#}

# ② バージョニング(state を誤って壊しても過去版に戻せる)
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}
