resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.project}-${var.env}"
  engine               = "redis"
  engine_version       = "5.0.4"
  node_type            = "cache.t2.micro"
  port                 = 6379
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.main.id
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.elasticache.id]
}

resource "aws_elasticache_parameter_group" "main" {
  name        = "${var.project}-${var.env}-redis-cache-params"
  family      = "redis5.0"
  description = "Cache cluster default param group"

  parameter {
    name  = "activerehashing"
    value = "yes"
  }
}

resource "aws_elasticache_subnet_group" "main" {
  name        = "${var.project}-${var.env}"
  description = "${var.env} CacheSubnetGroup"
  subnet_ids = [
    aws_subnet.private-primary.id,
    aws_subnet.private-secondary.id,
    aws_subnet.private-tertiary.id
  ]
}
