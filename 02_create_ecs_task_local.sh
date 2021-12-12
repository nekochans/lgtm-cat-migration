#!/usr/bin/env bash

if [ "$1" == "" ] || ([ "$1" != "stg" ] && [ "$1" != "prod" ])
then
  echo  "対象の環境を指定してください。stg, prod のみ指定できます。"
  exit 1
fi

env="$1"

FAMILY_NAME=${env}-lgtm-cat-migration

cat << EOF > ecs/task_definition.json
{
  "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/${env}-lgtm-cat-migration-ecs-task-execution-role",
  "containerDefinitions": [
    {
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${env}-lgtm-cat-migration",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "image": "${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${env}-lgtm-cat-migration",
      "name": "migration",
            "secrets": [
        {
          "name": "DB_HOSTNAME",
          "valueFrom": "/${env}/lgtm-cat/migration/DB_HOSTNAME"
        },
        {
          "name": "DB_USERNAME",
          "valueFrom": "/${env}/lgtm-cat/migration/DB_USERNAME"
        },
        {
          "name": "DB_NAME",
          "valueFrom": "/${env}/lgtm-cat/migration/DB_NAME"
        },
        {
          "name": "DB_PASSWORD",
          "valueFrom": "/${env}/lgtm-cat/migration/DB_PASSWORD"
        }
      ]
    }
  ],
  "memory": "512",
  "family": "${env}-lgtm-cat-migration",
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "networkMode": "awsvpc",
  "cpu": "256"
}
EOF

aws ecs register-task-definition \
  --family "${FAMILY_NAME}" \
  --cli-input-json file://ecs/task_definition.json \
  --region ap-northeast-1 --profile lgtm-cat
