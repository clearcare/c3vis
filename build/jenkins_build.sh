#!/bin/bash
set -e # Fail on any error

echo "Starting build!"
# Lets set these env vars, which the hook scripts use:

# forward slashes are not allowed in docker tags (this is what docker cloud does)
export GIT_BRANCH=`echo "$BRANCH_NAME" | tr / _`
export SOURCE_BRANCH=$GIT_BRANCH
export SOURCE_COMMIT=`git rev-parse --verify HEAD`
export DOCKER_REPO=index.docker.io/clearcare/c3vis
export IMAGE_NAME=index.docker.io/clearcare/c3vis:$GIT_BRANCH
# BASE_TAG is branch name:
export BASE_TAG=`echo "${SOURCE_BRANCH}" | tr / _`
# ADDITIONAL_TAG is the first 10 chars of the Git SHA:
export ADDITIONAL_TAG=`git rev-parse --short=10 --verify HEAD`
# Ideally this should be parameters:
export MAIN_LINE_BRANCH=master

echo "Building..."
# We need to strip out index.docker.io/ from DOCKER_REPO:
if [[ $DOCKER_REPO == *"index.docker.io/"* ]]; then
  DOCKER_IMAGE=${DOCKER_REPO:16}:$ADDITIONAL_TAG
  echo "DOCKER_IMAGE:$DOCKER_IMAGE"
else
  echo "index.docker.io/ not in $DOCKER_REPO. Failing."
  exit 1
fi

docker build --pull . -t $IMAGE_NAME
docker images || true

echo "Tagging..."

EPOCH_TIME_STAMP=$(date +%Y_%m_%d_%H_%M_%S)
# forward slashes are not allowed in docker tags
STANDARD_TAG=`echo "${EPOCH_TIME_STAMP}-${SOURCE_BRANCH}-${ADDITIONAL_TAG}" | tr / _`

# Push the base tag:
docker tag $IMAGE_NAME $DOCKER_REPO:$BASE_TAG
docker push $DOCKER_REPO:$BASE_TAG

# Push the standard tag:
docker tag $IMAGE_NAME $DOCKER_REPO:$STANDARD_TAG
docker push $DOCKER_REPO:$STANDARD_TAG

# Push the 10 char git sha tag:
docker tag $IMAGE_NAME $DOCKER_REPO:$ADDITIONAL_TAG
docker push $DOCKER_REPO:$ADDITIONAL_TAG

set +x # Do not print commands

if [[ $SOURCE_BRANCH == *"$MAIN_LINE_BRANCH"* ]]; then
  # Add the 'latest' tag
  docker tag $IMAGE_NAME $DOCKER_REPO:latest
  docker push $DOCKER_REPO:latest
fi

GREEN='\033[1;32m'
STOP="\033[m"
echo ""
echo -e "${GREEN}Docker Tags That Were Created: ${STOP}"
echo -e "${GREEN}********************************** ${STOP}"
echo -e "${GREEN}tag: ${DOCKER_REPO:16}:$STANDARD_TAG ${STOP}"
# Write the datetime tag to a file, so that Jenkins can update the
# Jenkins View for this build.
echo "$STANDARD_TAG" > jenkins.tag
echo -e "${GREEN}tag: ${DOCKER_REPO:16}:$ADDITIONAL_TAG ${STOP}"
echo -e "${GREEN}tag: ${DOCKER_REPO:16}:$BASE_TAG ${STOP}"
if [[ $SOURCE_BRANCH == *"$MAIN_LINE_BRANCH"* ]]; then
  echo -e "${GREEN}tag: ${DOCKER_REPO:16}:latest ${STOP}"
fi
echo -e "${GREEN}********************************** ${STOP}"
echo ""
echo -e "${GREEN}Build is Done! ${STOP}"
echo ""
set -x # Start printing commands:
