# 7:00 ECS Task 자동으로 실행하도록 설정
resource "aws_cloudwatch_event_rule" "batch_schedule" {
  name                = "mopl-batch-daily-7am"
  description         = "Run batch task every day at 07:00"
  schedule_expression = "cron(0 22 * * ? *)"
}

resource "aws_cloudwatch_event_target" "batch_movie" {
  rule      = aws_cloudwatch_event_rule.batch_schedule.name
  target_id = "mopl-batch-movie"
  arn       = aws_ecs_cluster.main.arn
  role_arn = aws_iam_role.eventbridge_ecs_role.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.batch.arn
    launch_type         = "FARGATE"
    task_count          = 1

    network_configuration {
      subnets          = [aws_subnet.private_a.id, aws_subnet.private_c.id]
      security_groups  = [aws_security_group.ecs.id]
      assign_public_ip = false
    }
  }

  input = jsonencode({
    containerOverrides = [
      {
        name    = local.batch_container_name
        command = ["--run.movie"]
      }
    ]
  })
}

resource "aws_cloudwatch_event_target" "batch_tvseries" {
  rule      = aws_cloudwatch_event_rule.batch_schedule.name
  target_id = "mopl-batch-tvseries"
  arn       = aws_ecs_cluster.main.arn
  role_arn = aws_iam_role.eventbridge_ecs_role.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.batch.arn
    launch_type         = "FARGATE"
    task_count          = 1

    network_configuration {
      subnets          = [aws_subnet.private_a.id, aws_subnet.private_c.id]
      security_groups  = [aws_security_group.ecs.id]
      assign_public_ip = false

    }
  }
  input = jsonencode({
    containerOverrides = [
      {
        name    = local.batch_container_name
        command = ["--run.tvSeries"]
      }
    ]
  })
}

resource "aws_cloudwatch_event_target" "batch_sport" {
  rule      = aws_cloudwatch_event_rule.batch_schedule.name
  target_id = "mopl-batch-sport"
  arn       = aws_ecs_cluster.main.arn
  role_arn = aws_iam_role.eventbridge_ecs_role.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.batch.arn
    launch_type         = "FARGATE"
    task_count          = 1

    network_configuration {
      subnets          = [aws_subnet.private_a.id, aws_subnet.private_c.id]
      security_groups  = [aws_security_group.ecs.id]
      assign_public_ip = false
    }
  }

  input = jsonencode({
    containerOverrides = [
      {
        name    = local.batch_container_name
        command = ["--run.sport"]
      }
    ]
  })
}
