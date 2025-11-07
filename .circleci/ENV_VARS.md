# CircleCI Environment Variables and Secrets

This file documents the environment variables and secrets used by `.circleci/config.yml` and how to set them in CircleCI.

## Required environment variables (set in CircleCI Project or Context)

- `AWS_DEFAULT_REGION` - AWS region for ECR/ECS (e.g. `us-east-1`).
- `AWS_ECR_REPOSITORY_URL` - Full ECR repository URI (e.g. `123456789012.dkr.ecr.us-east-1.amazonaws.com/my-repo`).
- `ECS_CLUSTER_NAME` - Name of the ECS cluster where the service runs.
- `ECS_SERVICE_NAME` - Name of the ECS service to update.
- `SECRETS_MANAGER_NAME` (optional) - Secrets Manager secret name to update with new IP (e.g. `prod/AgenticAI/Keys`).
- `SNYK_TOKEN` (optional) - Snyk token for authentication in pipeline.

## AWS Credentials (recommended setup)

CircleCI jobs need AWS credentials with permissions to push to ECR and manage ECS. There are two recommended ways to provide these credentials:

1. **Project Environment Variables (recommended for simple projects)**
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

   Add these in the CircleCI project settings -> Environment Variables.

2. **Contexts (recommended for teams / reusable across projects)**
   - Create a CircleCI Context and add the variables above.
   - Attach the context to the workflows/jobs that require AWS.

### Minimum IAM Permissions

The AWS principal used by CircleCI should have permissions similar to:

- `ecr:GetAuthorizationToken`, `ecr:BatchCheckLayerAvailability`, `ecr:PutImage`, `ecr:InitiateLayerUpload`, `ecr:UploadLayerPart`, `ecr:CompleteLayerUpload`
- `ecs:UpdateService`, `ecs:DescribeServices`, `ecs:DescribeClusters`, `ecs:RegisterTaskDefinition`, `ecs:DescribeTaskDefinition`, `ecs:ListTasks`, `ecs:DescribeTasks`
- `ec2:DescribeNetworkInterfaces`, `secretsmanager:GetSecretValue`, `secretsmanager:UpdateSecret`, `secretsmanager:CreateSecret`
- `sts:GetCallerIdentity`

Lock down permissions to the minimum required for security.

## Setting values locally (for testing)

You can export variables locally when testing pipeline scripts on your machine (do not commit real secrets):

```bash
export AWS_ACCESS_KEY_ID=AKIA...YOURKEY
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_DEFAULT_REGION=us-east-1
export AWS_ECR_REPOSITORY_URL=123456789012.dkr.ecr.us-east-1.amazonaws.com/my-repo
export ECS_CLUSTER_NAME=my-cluster
export ECS_SERVICE_NAME=my-service
export SECRETS_MANAGER_NAME=prod/AgenticAI/Keys
export SNYK_TOKEN=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## CircleCI tips

- Use `Contexts` for shared credentials across projects.
- Add `SNYK_TOKEN`, `AWS_*` variables in project settings, not in repo files.
- Use Branch filters in `workflows` to ensure deploys only run on `main` (already configured).
- No special orb permissions needed - we use direct npm/CLI commands for Snyk instead of the Snyk orb.

## Snyk Token Setup

To get a valid `SNYK_TOKEN`:

1. **Sign up/Login** to [Snyk.io](https://snyk.io)
2. **Generate API Token**:
   - Go to Account Settings → General → API Token
   - Or visit: https://app.snyk.io/account
   - Copy the token (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)
3. **Add to CircleCI**:
   - Project Settings → Environment Variables
   - Name: `SNYK_TOKEN`
   - Value: Your copied token

**Note**: If `SNYK_TOKEN` is missing or invalid, the pipeline will skip Snyk scanning but continue running other security checks.

## Troubleshooting

- **ECR login fails**: Verify `AWS_DEFAULT_REGION` and that the `AWS_*` credentials are valid.
- **ECS commands fail**: Check IAM permissions and that `ECS_CLUSTER_NAME` / `ECS_SERVICE_NAME` are correct.
- **Snyk authentication fails**: 
  - Ensure `SNYK_TOKEN` is set correctly in CircleCI environment variables
  - Verify token is not expired (regenerate if needed)
  - Check that your Snyk account has access to scan the project
  - Visit https://app.snyk.io/account to get a fresh token
