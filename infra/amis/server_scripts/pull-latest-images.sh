#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_REGION=$(aws configure list | grep region | awk '{print $2}')

# Login to AWS ECR
# aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Get a list of all repository names in your AWS ECR
REPO_NAMES=$(aws ecr describe-repositories | jq -r '.repositories[].repositoryName')

for REPO_NAME in $REPO_NAMES; do
  # For each repository, get the latest image tag
  LATEST_IMAGE_TAG=$(aws ecr describe-images --repository-name "$REPO_NAME" --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' --output text)
  
  # Construct the full image name

  IMAGE_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$LATEST_IMAGE_TAG"

  # Pull the latest image
  echo "Pulling latest image for repository $REPO_NAME: $IMAGE_URI"
  docker pull --quiet "$IMAGE_URI"
done

echo "Completed pulling latest images from all ECR repositories."
