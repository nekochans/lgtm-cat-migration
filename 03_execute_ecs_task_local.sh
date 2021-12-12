#!/usr/bin/env bash

if [ "$1" == "" ] || ([ "$1" != "stg" ] && [ "$1" != "prod" ])
then
  echo  "対象の環境を指定してください。stg, prod のみ指定できます。"
  exit 1
fi

env="$1"
FAMILY_NAME=${env}-lgtm-cat-migration

if [ "${env}" == "stg" ]
then
  SECURITY_GROUP_ID=${STG_SECURITY_GROUP_ID}
else
  SECURITY_GROUP_ID=${PROD_SECURITY_GROUP_ID}
fi

TASK_DEF_ARN=$(aws ecs list-task-definitions \
  --family-prefix "${FAMILY_NAME}" \
  --query "reverse(taskDefinitionArns)[0]" \
  --output text \
  --region ap-northeast-1 --profile lgtm-cat)

NETWORK_CONFIG="awsvpcConfiguration={subnets=[${SUBNET_ID}],securityGroups=[${SECURITY_GROUP_ID}],assignPublicIp=ENABLED}"

aws ecs run-task \
  --cluster "${env}"-lgtm-cat-migration-cluster \
  --task-definition "${TASK_DEF_ARN}" \
  --launch-type FARGATE \
  --network-configuration "${NETWORK_CONFIG}" \
  --overrides "{\"containerOverrides\": [{\"name\": \"migration\",\"command\": [\"./migrate_up.sh\"]}]}" \
  --region ap-northeast-1 --profile lgtm-cat
