#!/usr/bin/env bash

if [ "$1" == "" ] || ([ "$1" != "stg" ] && [ "$1" != "prod" ])
then
  echo  "対象の環境を指定してください。stg, prod のみ指定できます。"
  exit 1
fi

env="$1"
repository=${env}-lgtm-cat-migration

aws ecr get-login-password --profile lgtm-cat --region ap-northeast-1 | docker login --username AWS --password-stdin "${ACCOUNT_ID}".dkr.ecr.ap-northeast-1.amazonaws.com/"${repository}"

docker build -t "${ACCOUNT_ID}".dkr.ecr.ap-northeast-1.amazonaws.com/${repository}:latest -f docker/migrate/Dockerfile .
docker push "${ACCOUNT_ID}".dkr.ecr.ap-northeast-1.amazonaws.com/${repository}:latest
