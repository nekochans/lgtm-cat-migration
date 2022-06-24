# lgtm-cat-migration
LGTMeowで利用するDBのmigrationを行う

## Getting Started

### インストール
- AWS CLI

### 環境変数の設定

環境変数の設定を行います。

[direnv](https://github.com/direnv/direnv) 等の利用を推奨します。

設定が必要な環境変数は下記の通りです。

```
# ローカル環境用
export DB_HOSTNAME=mysql
export DB_USERNAME=DBのユーザー名
export DB_PASSWORD=DBのパスワード
export DB_NAME=DB名

# ECS実行用
export SUBNET_ID=ECSタスクを実行するサブネットグループID
export STG_SECURITY_GROUP_ID=STG環境用 ECSタスクに設定するセキュリテイグループ
export PROD_SECURITY_GROUP_ID=PROD環境用 ECSタスクに設定するセキュリテイグループ
export ACCOUNT_ID=AWSのアカウントID
```

### ローカルでの環境構築

`docker-compose up -d` でコンテナを起動します。

## Migration の追加手順

### 1. Migration ファイルの追加

Migration をツールは [migrate](https://github.com/golang-migrate/migrate) を利用します。

`create_new_migration_file.sh` を利用すると、空の Migration ファイルを作成出来ますので、そこに SQL を書いていきます。

`create_new_migration_file.sh` に渡す引数ですが、命名規則は以下のような形になっています。

- `create_[テーブル名]`
- `add_column_[追加するカラム名]`
- `add_index_[追加するカラム名]`

実行例は以下の通りです。

```bash
./create_new_migration_file.sh create_users

# これらのファイルが作成される
created ./migrations/20210807151547_create_users.up.sql
created ./migrations/20210807151547_create_users.down.sql
```

### 2. Migration の実行を行う

`./migrate_up.sh` を実行して Migration を実行します。

Migration のロールバックを行う際は `./migrate_down.sh` を実行します。

ローカル開発環境の場合、migrate コンテナ上で実行する必要があります。

## AWS 上での Migration 実行方法

ECSタスクで migration を実行します。
ローカル環境から下記のスクリプトを実行してください。

下記のリソースは Terraform で管理しています。

- ECS Cluster
- ECR
- IAM
- SecurityGroup
- CloudWatch Logs

### 前提条件

データベースとユーザーが作成されている必要があります。

#### DBへの接続

踏み台用のコンテナから DB に接続します。

下記のインストールが必要です。

- AWS CLI v2 バージョン 2.1.31以降
    - 参考：[AWS CLI バージョン 2 のインストール、更新、アンインストール - AWS Command Line Interface](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/install-cliv2.html)
- Session Manager プラグイン
    - 参考：[(オプション) AWS CLI 用の Session Manager プラグインをインストールする - AWS Systems Manager](https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

ECS Service `lgtm-cat-bastion-service` の Desired count を1に変更し、タスクを起動します。

下記のコマンドを実行します。

```shell
aws ecs execute-command  \
    --profile lgtm-cat \
    --region ap-northeast-1 \
    --cluster lgtm-cat-bastion-cluster \
    --task <タスクID> \
    --container bastion \
    --command "/bin/sh" \
    --interactive
```

#### データベースとユーザーの作成

MySQL へ接続します。

```
mysql -h ホスト名 -P 3306 -u ユーザー名 -p
```

下記のコマンドを実行してデータベースとユーザーを作成してください。

```sql
CREATE DATABASE your_database;
CREATE USER your_user@'%' IDENTIFIED WITH mysql_native_password BY 'YourPassword';
GRANT ALL ON your_database.* TO 'your_user'@'%';
```

### Docker イメージのビルドと ECR へのプッシュ

Docker の新規作成時、変更時に実行します。

```bash
./01_push_ecr_local.sh <stg|prod>
```

### ECS タスクの定義の作成

ECS タスクの定義の新規作成時、変更時に実行します。

```bash
./02_create_ecs_task_local.sh <stg|prod>
```

### ECS タスクの実行

migration の際に実行します。

```bash
./03_execute_ecs_task_local.sh <stg|prod>
```
