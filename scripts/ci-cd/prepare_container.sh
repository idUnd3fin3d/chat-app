#!/bin/bash

IMAGE_TAG=$DOCKER_REGISTRY_HOST/$CI_PROJECT_NAME/$CI_COMMIT_REF_SLUG:$CI_COMMIT_SHA

echo $IMAGE_TAG > image_ref

if [ $BUILD_TARGET == "prod" ]; then
  APP_API_URL=$APP_API_URL_PROD
  APP_WS_URL=$APP_WS_URL_PROD
else
  APP_API_URL=$APP_API_URL_DEV
  APP_WS_URL=$APP_WS_URL_DEV
fi

docker build --build-arg API_URL=$APP_API_URL --build-arg WS_URL=$APP_WS_URL --target=$BUILD_TARGET -t $IMAGE_TAG .
docker push $IMAGE_TAG
docker image rm $IMAGE_TAG
