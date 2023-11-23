#!/usr/bin/env bash
API_NAME="echo-api"
REGION=eu-central-1
STAGE=test

LAMBDA_NAME="aws-echo-lambda"

set -x
## This file is used for local development only
#create_lambda_repo(){
#  awslocal ecr create-repository \
#    --region ${REGION} \
#    --repository-name $1
#}
#
#create_lambda_repo ${LAMBDA_NAME}

# Create function (fails on start, need push image to local ecr)

awslocal lambda create-function \
  --region ${REGION} \
  --function-name ${LAMBDA_NAME} \
  --package-type Image \
  --code ImageUri="draqun/${LAMBDA_NAME}:latest" \
  --handler main.lambda_handler \
  --environment "Variables={LOGGING_LVL=\"DEBUG\"}" \
  --role arn:aws:iam::000000000000:role/lambda-role


# Create API Gateway
awslocal apigateway create-rest-api \
  --region ${REGION} \
  --name ${API_NAME}
[ $? == 0 ] || fail 2 "Failed: AWS / apigateway / create-rest-api"

API_ID=$(awslocal apigateway get-rest-apis --query "items[?name==\`${API_NAME}\`].id" --output text --region ${REGION})
PARENT_RESOURCE_ID=$(awslocal apigateway get-resources --rest-api-id ${API_ID} --query 'items[?path==`/`].id' --output text --region ${REGION})

# Function to add endpoint
add_endpoint(){
  # $1 - parent-id
  # $2 - path-part
  # $3 - method
  awslocal apigateway create-resource \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --parent-id $1 \
    --path-part $2
  [ $? == 0 ] || fail 3 "Failed: AWS / apigateway / create-resource"

  ENDPOINT_ID=$(awslocal apigateway get-resources --rest-api-id ${API_ID} --query "items[?pathPart==\`$2\`].id" --output text --region ${REGION})
  awslocal apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${ENDPOINT_ID} \
    --http-method $3 \
    --authorization-type "NONE"
  [ $? == 0 ] || fail 4 "Failed: AWS / apigateway / put-method"

  awslocal apigateway put-integration \
      --region ${REGION} \
      --rest-api-id ${API_ID} \
      --resource-id ${ENDPOINT_ID} \
      --http-method $3 \
      --type AWS_PROXY \
      --integration-http-method $3 \
      --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/arn:aws:lambda:${REGION}:000000000000:function:$2/invocations \
      --passthrough-behavior WHEN_NO_MATCH
  [ $? == 0 ] || fail 5 "Failed: AWS / apigateway / put-integration"
}

# ADD delete-charging-station-from-hubject
add_endpoint $PARENT_RESOURCE_ID $LAMBDA_NAME "POST"

awslocal apigateway create-deployment \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --stage-name ${STAGE}
[ $? == 0 ] || fail 6 "Failed: AWS / apigateway / create-deployment"

set +x
