provider "aws" {
  version = "~> 2.0"
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
    userdata        = <<-EOF
        #!/bin/bash
        echo ${module.network.route_table_assoc}
        yum install -y httpd-tools git
        git config --system credential.helper '!aws codecommit credential-helper $@'
        git config --system credential.UseHttpPath true
        git config --system user.email "labs@pluralsight.com"
        git config --system user.name "Pluralsight Labs"
        git clone ${aws_codecommit_repository.globomantics.clone_url_http} codecommit
        git clone https://github.com/ps-interactive/lab_aws_implement-auto-scaling-amazon-ecs github
        mv github/* codecommit/
        cd codecommit
        git add -A
        git commit -m "Initial commit"
        git push 
        git checkout -b ${lower(var.environment)}
        git push --set-upstream origin ${lower(var.environment)}
    EOF
}

module "webapp" {
    source              = "./modules/infrastructure/asg_and_alb"
    project_name        = module.network.project_name
    environment         = module.network.environment
    vpc                 = module.network.vpc
    private_subnets     = module.network.private_subnets
    public_subnets      = module.network.public_subnets
    base_ami            = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
    iam_policies        = local.instance_policies
    userdata            = <<-EOF
        #!/bin/bash
        echo ${module.network.route_table_assoc}
        echo "ECS_CLUSTER=${local.name_tag_prefix}-EcsCluster" >> /etc/ecs/ecs.config
        yum install -y iptables-services; sudo iptables --insert FORWARD 1 --in-interface docker+ --destination 169.254.169.254/32 --jump DROP
        iptables-save | sudo tee /etc/sysconfig/iptables && sudo systemctl enable --now iptables
    EOF
}

resource "time_sleep" "wait_5_mins" {
  depends_on = [module.cicdGlobomantics]

  create_duration = "5m"
}

# What follows is a hard coded list of pipelines. When 0.13 is released
# and for_each for modules stabilizes, this should be changed to refer 
# to the services map.

module "cicdGlobomantics" {
    source                          = "./modules/cicd/ecs"
    project_name                    = module.network.project_name
    environment                     = module.network.environment
    service                         = "home"
    git_repo                        = "globomantics"
    codedeploy_app                  = aws_codedeploy_app.services.name
    codedeploy_deployment_group     = aws_codedeploy_deployment_group.services["home"].deployment_group_name
}
