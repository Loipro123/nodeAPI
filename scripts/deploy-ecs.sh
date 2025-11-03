#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/deploy-ecs.sh <cluster> <service> <region> <image> [secrets-manager-name]
# Example: ./scripts/deploy-ecs.sh my-cluster my-service us-east-1 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-repo:abcdef "prod/AgenticAI/Keys"

CLUSTER=${1:-}
SERVICE=${2:-}
REGION=${3:-}
IMAGE=${4:-}
SECRETS_MANAGER_NAME=${5:-}

if [ -z "$CLUSTER" ] || [ -z "$SERVICE" ] || [ -z "$REGION" ] || [ -z "$IMAGE" ]; then
  echo "Usage: $0 <cluster> <service> <region> <image> [secrets-manager-name]"
  exit 2
fi

echo "Updating ECS service: cluster=$CLUSTER service=$SERVICE region=$REGION image=$IMAGE"

# get current task def
TASK_DEF_ARN=$(aws ecs describe-services --cluster "$CLUSTER" --services "$SERVICE" --region "$REGION" --query 'services[0].taskDefinition' --output text)
if [ -z "$TASK_DEF_ARN" ] || [ "$TASK_DEF_ARN" = "None" ]; then
  echo "Failed to find task definition for service $SERVICE in cluster $CLUSTER"
  exit 1
fi

echo "Current task definition: $TASK_DEF_ARN"

aws ecs describe-task-definition --task-definition "$TASK_DEF_ARN" --region "$REGION" --query 'taskDefinition' > task-def.json

# update container image (assumes single container in definition)
jq --arg IMAGE "$IMAGE" \
  '.containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.placementConstraints) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)' \
  task-def.json > new-task-def.json

# register new task def
NEW_TASK_DEF_ARN=$(aws ecs register-task-definition --cli-input-json file://new-task-def.json --region "$REGION" --query 'taskDefinition.taskDefinitionArn' --output text)

echo "Registered new task definition: $NEW_TASK_DEF_ARN"

# update service to use new task def
aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" --task-definition "$NEW_TASK_DEF_ARN" --region "$REGION"

echo "Service update triggered, waiting for stability..."

# wait for stable (timeout 10m)
if timeout 10m aws ecs wait services-stable --cluster "$CLUSTER" --services "$SERVICE" --region "$REGION"; then
  echo "Service is stable"
else
  echo "Service did not become stable within timeout"
  aws ecs describe-services --cluster "$CLUSTER" --services "$SERVICE" --region "$REGION" --query 'services[0].{Status:status,RunningCount:runningCount,DesiredCount:desiredCount,Events:events[0:3]}'
  exit 1
fi

# optionally update secrets manager with task ENI public IP
if [ -n "$SECRETS_MANAGER_NAME" ]; then
  echo "Getting running task ARN..."
  TASK_ARN=$(aws ecs list-tasks --cluster "$CLUSTER" --service-name "$SERVICE" --region "$REGION" --query 'taskArns[0]' --output text)
  if [ -z "$TASK_ARN" ] || [ "$TASK_ARN" = "None" ]; then
    echo "No running task found"
    exit 0
  fi

  ENI_ID=$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASK_ARN" --region "$REGION" --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)
  if [ -z "$ENI_ID" ] || [ "$ENI_ID" = "None" ]; then
    echo "No ENI found for task $TASK_ARN"
    exit 0
  fi

  PUBLIC_IP=$(aws ec2 describe-network-interfaces --network-interface-ids "$ENI_ID" --region "$REGION" --query 'NetworkInterfaces[0].Association.PublicIp' --output text)
  if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" = "None" ]; then
    echo "No public IP for ENI $ENI_ID"
    exit 0
  fi

  TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
  CURRENT_SECRET=$(aws secretsmanager get-secret-value --secret-id "$SECRETS_MANAGER_NAME" --region "$REGION" --query 'SecretString' --output text 2>/dev/null || echo "{}")
  NEW_SECRET=$(echo "$CURRENT_SECRET" | jq --arg ip "$PUBLIC_IP" --arg ts "$TIMESTAMP" '. + {api_ip_address: $ip, last_updated: $ts, deployment_source: "scripts/deploy-ecs.sh"}')

  aws secretsmanager update-secret --secret-id "$SECRETS_MANAGER_NAME" --secret-string "$NEW_SECRET" --region "$REGION" || \
    aws secretsmanager create-secret --name "$SECRETS_MANAGER_NAME" --secret-string "$NEW_SECRET" --region "$REGION"

  echo "Updated Secrets Manager secret $SECRETS_MANAGER_NAME with new IP: $PUBLIC_IP"
fi

echo "Deployment completed successfully"
