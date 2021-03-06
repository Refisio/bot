#!/bin/bash

# Build and deploy on master branch
if [[ $CI_COMMIT_REF_SLUG == 'master' ]]; then
    echo "Connecting to docker hub"
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

    changed_lines=$(git diff HEAD~1 HEAD docker/base.Dockerfile | wc -l)

    if [ $changed_lines != '0' ]; then
      echo "base.Dockerfile was changed"

      echo "Building bot base"
      docker build -t pythondiscord/bot-base:latest -f docker/base.Dockerfile .

      echo "Pushing image to Docker Hub"
      docker push pythondiscord/bot-base:latest
    else
      echo "base.Dockerfile was not changed, not building"
    fi

    echo "Building image"
    docker build -t pythondiscord/bot:latest -f docker/bot.Dockerfile .

    echo "Pushing image"
    docker push pythondiscord/bot:latest

    echo "Deploying container"
    curl -H "token: $AUTODEPLOY_TOKEN" $AUTODEPLOY_WEBHOOK
else
    echo "Skipping deploy"
fi
