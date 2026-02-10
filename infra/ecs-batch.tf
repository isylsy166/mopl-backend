locals {
  batch_name           = "mopl-batch"
  batch_container_name = "mopl-batch"
}

# ----------------------------------------------------------------------

resource "aws_ecs_task_definition" "batch" {
  family                   = local.batch_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = 512
  memory = 1024

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = local.batch_container_name
      image     = "${data.aws_ecr_repository.mopl_batch.repository_url}:release-${var.batch_image_uri}"
      essential = true

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = data.aws_ssm_parameter.db_password.arn
        },
        {
          name      = "TMDB_API_TOKEN"
          valueFrom = data.aws_ssm_parameter.tmdb_api_token.arn
        }
      ]

      environment = [
        {
          name  = "TZ"
          value = "Asia/Seoul"
        },
        {
          name  = "SPRING_PROFILES_ACTIVE"
          value = var.environment  # 여기서 프로필을 결정
        },
        {
          name  = "DB_URL"
          value = aws_db_instance.main.address
        },
        {
          name  = "DB_USERNAME"
          value = aws_db_instance.main.username
        },
        {
          name = "REDIS_HOST_PROD"
          value = aws_instance.redis.private_ip
        },
        {
          name = "AWS_REGION"
          value = data.aws_ssm_parameter.aws_region.value
        },
        {
          name = "AWS_S3_BUCKET"
          value = data.aws_ssm_parameter.aws_s3_bucket.value
        },
        {
          name = "REDIS_HOST_PROD"
          value = aws_instance.redis.private_ip
        },
        {
          name = "REDIS_PORT"
          value = "6379"
        },
        {
          name = "KAFKA_BOOTSTRAP_SERVERS_PROD"
          value = "${aws_instance.kafka.private_ip}:9092"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_batch.name
          awslogs-region        = "ap-northeast-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

