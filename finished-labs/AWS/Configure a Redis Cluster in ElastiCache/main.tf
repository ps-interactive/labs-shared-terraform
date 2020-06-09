variable "aws_region" {
  default = "us-west-2"
}

provider "aws" {
  version = "~> 2.0"
  region     = var.aws_region
}

resource "aws_vpc" "redis_cluster_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "allow_redis" {
  name        = "allow_redis"
  description = "Allow Redis inbound traffic"
  vpc_id      = aws_vpc.redis_cluster_vpc.id

  ingress {
    description = "Redis from VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_redis"
  }
}

resource "aws_subnet" "redis_cluster_subnet_one" {
  vpc_id            = aws_vpc.redis_cluster_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "RedisClusterSubnet1"
  }
}

resource "aws_subnet" "redis_cluster_subnet_two" {
  vpc_id            = aws_vpc.redis_cluster_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "RedisClusterSubnet2"
  }
}

resource "aws_elasticache_subnet_group" "lab_redis_subnet_group" {
  name       = "lab-redis-subnet-group"
  subnet_ids = [aws_subnet.redis_cluster_subnet_one.id,aws_subnet.redis_cluster_subnet_two.id]
}

resource "aws_elasticache_replication_group" "complex" {
  replication_group_id          = "complex-redis-cluster-group"
  replication_group_description = "2 Shards 2 nodes each, 1 primary 1 replica"
  node_type                     = "cache.t2.micro"
  engine               = "redis"
  engine_version       = "5.0.6"
  port                          = 6379
  parameter_group_name          = "default.redis5.0.cluster.on"
  security_group_ids            = [aws_security_group.allow_redis.id]
  subnet_group_name    = aws_elasticache_subnet_group.lab_redis_subnet_group.name
  automatic_failover_enabled    = true

  cluster_mode {
    replicas_per_node_group = 1
    num_node_groups         = 2
  }
}

resource "aws_elasticache_replication_group" "simple_repl" {
  replication_group_id          = "simple-redis-cluster-group"
  replication_group_description = "1 Shard 2 nodes each, 1 primary 1 replica"
  node_type                     = "cache.t2.small"
  engine               = "redis"
  engine_version       = "5.0.6"
  port                          = 6379
  parameter_group_name          = "default.redis5.0.cluster.on"
  security_group_ids            = [aws_security_group.allow_redis.id]
  subnet_group_name    = aws_elasticache_subnet_group.lab_redis_subnet_group.name
  automatic_failover_enabled    = true

  cluster_mode {
    replicas_per_node_group = 1
    num_node_groups         = 1
  }
}

resource "aws_elasticache_cluster" "simple" {
  cluster_id           = "simple-redis-cluster"
  engine               = "redis"
  engine_version       = "5.0.6"
  node_type                     = "cache.t2.micro"
  num_cache_nodes               = 1
  parameter_group_name          = "default.redis5.0"
  security_group_ids            = [aws_security_group.allow_redis.id]
  port                          = 6379
  subnet_group_name    = aws_elasticache_subnet_group.lab_redis_subnet_group.name
}
