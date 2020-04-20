resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier              = "${var.project}-${var.env}-aurora-cluster"
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.12"
  database_name                   = "event_organizer"
  master_username                 = "organizer"
  master_password                 = "XJvKqaR45Epy"
  backup_retention_period         = 7
  preferred_backup_window         = "03:00-03:30"
  preferred_maintenance_window    = "sun:04:00-sun:04:30"
  vpc_security_group_ids          = [aws_security_group.aurora.id]
  db_subnet_group_name            = aws_db_subnet_group.main.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  final_snapshot_identifier       = "${var.project}-${var.env}-aurora-cluster"
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]
  deletion_protection             = true

  lifecycle {
    ignore_changes = [master_password]
  }
}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
  count                   = "3"
  identifier              = "${var.project}-${var.env}-aurora-instance-${count.index}"
  cluster_identifier      = aws_rds_cluster.aurora_cluster.id
  engine                  = "aurora-mysql"
  instance_class          = "db.t3.small"
  db_subnet_group_name    = aws_db_subnet_group.main.name
  db_parameter_group_name = aws_db_parameter_group.main.name
  publicly_accessible     = false

  tags = {
    Name        = "${var.project}-${var.env}-${count.index}"
    Group       = var.project
    ManagedBy   = "terraform"
    Environment = var.env
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [instance_class]
  }
}

resource "aws_db_subnet_group" "main" {
  name        = "${var.project}-${var.env}"
  description = "${var.env} group of subnets"
  subnet_ids = [
    aws_subnet.private-primary.id,
    aws_subnet.private-secondary.id,
    aws_subnet.private-tertiary.id
  ]

  tags = {
    Name = "${var.project} DB subnet group"
  }
}

resource "aws_rds_cluster_parameter_group" "main" {
  name        = "${var.project}-${var.env}-aurora-pg"
  family      = "aurora-mysql5.7"
  description = "RDS parameter group for ${var.project}"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  lifecycle {
    ignore_changes = [parameter]
  }
}

resource "aws_db_parameter_group" "main" {
  name        = "${var.project}-${var.env}-pg"
  family      = "aurora-mysql5.7"
  description = "RDS parameter group for ${var.project}"

  parameter {
    name  = "max_connections"
    value = "512"
  }

  parameter {
    name         = "slow_query_log"
    value        = 1
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "long_query_time"
    value        = 1
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_output"
    value        = "file"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "query_cache_type"
    value        = 1
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "general_log"
    value        = 1
    apply_method = "pending-reboot"
  }
}
