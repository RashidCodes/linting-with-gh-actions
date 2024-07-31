terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}


variable "cluster_arn" {
  type = string
}

variable "ecr_repo" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "aws_region" {
  type = string
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

resource "aws_iam_role" "role" {
  // IAM role that lets us write to Cloudwatch logs and pull from ECR
  name = "dbt-task-execution-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "policy" {
  name = "ecs-cloudwatch-ecr-policy"
  role = aws_iam_role.role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:Create*",
          "logs:Put*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_ecs_task_definition" "task_definition" {
  family             = "my-dbt-task-definition"
  execution_role_arn = aws_iam_role.role.arn
  // https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html
  container_definitions = jsonencode([
    {
      name = "list-dbt-models"
      // role assumed by the container
      executionRoleArn = aws_iam_role.role.arn
      // Commands to run in the container
      command = [
        "sh",
        "-c",
        "dbt deps && dbt ls",
      ]
      environment = [
        {
          name  = SNOWFLAKE_ACCOUNT
          value = env.SNOWFLAKE_ACCOUNT
        },
        {
          name  = SNOWFLAKE_USERNAME
          value = env.SNOWFLAKE_USERNAME
        },
        {
          name  = SNOWFLAKE_PASSWORD
          value = env.SNOWFLAKE_PASSWORD
        },
        {
          name  = SNOWFLAKE_ROLE
          value = env.SNOWFLAKE_ROLE
        },
      ]
      // the image
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.ecr_repo}:${var.image_tag}"
      cpu       = 256 // this translates to 0.25 vCPU. T2 micro only has 1 vCPU.
      memory    = 128 // 128 MiB
      essential = true
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group = "/ecs/dbt-task-definition",
          awslogs-region : "${data.aws_region.current.name}",
          awslogs-stream-prefix : "ecs",
          awslogs-create-group : "true",
        }
      }
    }
    // you can add more steps in the the task list
    // this can be useful if you want to break down into smaller steps such as
    // dbt compile, dbt test, dbt build
  ])
}

// The worker keeps listening in for new tasks
// This could be useful if you want something to be always processing
resource "aws_ecs_service" "worker" {
  name            = "worker"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
}


// An alternative is to create one off tasks or scheduled tasks:
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_set
// https://registry.terraform.io/modules/tmknom/ecs-scheduled-task/aws/latest