provider "aws" {
  profile = "terraform"
  region  = "us-west-2"
}

module "network" {
    source          = "./modules/infrastructure/network"
    project_name    = var.project_name
    environment     = var.environment
    db_port         = var.db_port
    networks        = var.networks
}

module "instances" {
    source  = "./modules/infrastructure/instances"
    project_name    = module.network.project_name
    environment     = module.network.environment
    db_port         = module.network.db_port
    vpc             = module.network.vpc
    private_subnets = module.network.private_subnets
    public_subnets  = module.network.public_subnets
    db_subnets      = module.network.db_subnets
    db_subnet_group = module.network.db_subnet_group
}
