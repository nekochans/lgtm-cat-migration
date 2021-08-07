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
export SECURITY_GROUP_ID=ECSタスクに設定するセキュリテイグループ
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

## AWS 上での Migration 実行方法

ECSタスクで migration を実行します。
ローカル環境から下記のスクリプトを実行してください。

下記のリソースは Terraform で管理しています。

- ECS Cluster
- ECR
- IAM
- SecurityGroup
- CloudWatch Logs

### Docker イメージのビルドと ECR へのプッシュ

Docker の新規作成時、変更時に実行します。

```bash
./push_ecr_local.sh
```

### ECS タスクの定義の作成

ECS タスクの定義の新規作成時、変更時に実行します。

```bash
./create_ecs_task_local.sh
```

### ECS タスクの実行

migration の際に実行します。

```bash
./execute_ecs_task_local.sh
```
