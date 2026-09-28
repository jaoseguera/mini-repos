#!/bin/bash
set -e

ENV=${1:-dev}
REGION="us-east-1"
AWS_PROFILE=${2:-personal}
CODE_VERSION="v1.0.0"
APP_NAME="react-aws-app"
BUCKET="$APP_NAME-lambdas-$ENV"
STACK_NAME="$APP_NAME-rds-stack-$ENV"

VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" \
  --output text --region $REGION)

if [ "$VPC_ID" == "None" ] || [ -z "$VPC_ID" ]; then
  echo "Error: Default VPC not found!"
  exit 1
fi

# ─── COGNITO INFORMATION ──────────────────────────────────────────────────────────────
echo "Getting Cognito information..."
COGNITO_USERPOOLID=$(aws cognito-idp list-user-pools --max-results 1 \
  --region $REGION \
  --query "UserPools[?contains(Name, 'react')].Id" \
  --output text)
COGNITO_CLIENTID=$(aws cognito-idp list-user-pool-clients \
  --user-pool-id $COGNITO_USERPOOLID \
  --region $REGION \
  --query "UserPoolClients[0].ClientId" \
  --output text)

# ─── CLOUDFORMATION DEPLOYMENT ────────────────────────────────────────────────
echo "Deploying CloudFormation stack..."
aws cloudformation deploy \
  --stack-name $STACK_NAME \
  --template-file ../stacks/02_rds.yml \
  --parameter-overrides Environment=$ENV VpcId=$VPC_ID AppName=$APP_NAME CodeVersion=$CODE_VERSION Bucket=$BUCKET \
  CognitoUserPoolId=$COGNITO_USERPOOLID CognitoClientId=$COGNITO_CLIENTID\
  --capabilities CAPABILITY_NAMED_IAM \
  --region $REGION