#!/usr/bin/env bash

FAMILY_NAME=lgtm-cat-migration

TASK_DEF_ARN=$(aws ecs list-task-definitions \
  --family-prefix "${FAMILY_NAME}" \
  --query "reverse(taskDefinitionArns)[0]" \
  --output text \
  --region ap-northeast-1 --profile lgtm-cat)

NETWORK_CONFIG="awsvpcConfiguration={subnets=[${SUBNET_ID}],securityGroups=[${SECURITY_GROUP_ID}],assignPublicIp=ENABLED}"


aws ecs run-task \
  --cluster lgtm-cat-migration-cluster \
  --task-definition "${TASK_DEF_ARN}" \
  --launch-type FARGATE \
  --network-configuration "${NETWORK_CONFIG}" \
  --overrides "{\"containerOverrides\": [{\"name\": \"migration\",\"command\": [\"./migrate_up.sh\"]}]}" \
  --region ap-northeast-1 --profile lgtm-cat
