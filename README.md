# receipt-scanner-infra
[家計簿くん](https://github.com/AyumuOgasawara/receipt-scanner)のインフラリソースを構成・管理するディレクトリ<br>

## システム構成図
![receipt-scanner-infrav3](https://github.com/user-attachments/assets/68561059-44c7-4a7f-b372-4534d072ab4b)

### アプリ構成
- フロントエンド：Next.js
- バックエンド：Next.js
- ORM：Prisma

### データベース
- RDS：PostgreSQL

### レシート解析API
- 言語；Python
- 使用モデル：Tesseract・pytesseract
- ライブラリ：FastAPI

### リバースプロキシ
- サーバー：Nginx

## 必要条件

### IAMユーザーの作成
[AWS](https://aws.amazon.com/jp/)のリソースを利用してインフラを構成しています。<br>
IAMユーザーを作成し、`Access key ID`と`Secret access key`を取得してください。

### AWS CLI 認証情報の設定
[AWS CLI の設定手順](https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-configure.html)に従って`AWS CLI`の認証情報を設定してください。
- 以下のコマンドを入力し、IAMユーザー情報が出力されれば設定は完了です。
    ``` sh
    aws iam get-user
    ```

### Terraformのインストール
Terraformをインストールするには、[公式ドキュメント](https://developer.hashicorp.com/terraform/install)を参照してください。


### 環境変数の設定
| 環境変数 | 説明 |
| ------------ | ------- |
| access_key | IAM ユーザーの Access key ID |
| secret_key | IAM ユーザーの Secret access key |
| key_file_path | キーペアファイルを保存するディレクトリ |
| rds_db_name |　 RDSのデータベースの名前 |
| rds_user_name |　RDSのユーザーネーム |
| rds_password |　 RDSのパスワード |
| vpc_cidr_block | VPCのCIDRブロック |

## 実行方法
- 初期化<br>
``` sh
terraform init
```

- 現在の構成との差分を表示する<br>
``` sh
terraform plan
```

- インフラストラクチャを作成・更新<br>
``` sh
terraform apply
```

- 既存のインフラストラクチャを破棄する<br>
``` sh
terraform destroy
```

## 開発者向け
### フォーマット
以下を実行してからコミットしてください。
``` sh
terraform fmt
```