#!/usr/bin/env bash

FAMILY_NAME=lgtm-cat-migration

cat << EOF > ecs/task_definition.json
{
  "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/lgtm-cat-migration-ecs-task-execution-role",
  "containerDefinitions": [
    {
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "lgtm-cat-migration",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "image": "${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/lgtm-cat-migration",
      "name": "migration",
            "secrets": [
        {
          "name": "DB_HOSTNAME",
          "valueFrom": "/lgtm-cat/migration/DB_HOSTNAME"
        },
        {
          "name": "DB_USERNAME",
          "valueFrom": "/lgtm-cat/migration/DB_USERNAME"
        },
        {
          "name": "DB_NAME",
          "valueFrom": "/lgtm-cat/migration/DB_NAME"
        },
        {
          "name": "DB_PASSWORD",
          "valueFrom": "/lgtm-cat/migration/DB_PASSWORD"
        }
      ]
    }
  ],
  "memory": "512",
  "family": "lgtm-cat-migration",
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
