#!/usr/bin/env bash

repository=lgtm-cat-migration

aws ecr get-login-password --profile lgtm-cat --region ap-northeast-1 | docker login --username AWS --password-stdin "${ACCOUNT_ID}".dkr.ecr.ap-northeast-1.amazonaws.com/${repository}

docker build -t "${ACCOUNT_ID}".dkr.ecr.ap-northeast-1.amazonaws.com/${repository}:latest -f docker/migrate/Dockerfile .
docker push "${ACCOUNT_ID}".dkr.ecr.ap-northeast-1.amazonaws.com/${repository}:latest
