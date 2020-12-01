variable "project_name" {
  type        = string
  default     = "Demo"
  description = "Project name for tagging purposes"
}

variable "environment" {
  type        = string
  default     = "Dev"
  description = "Environment name for tagging purposes"
}

variable "db_port" {
  type        = number
  default     = 5432
  description = "Port of the database being used"
}

# NOTE: THERE IS AN ASSUMPTION THAT PUBLIC SUBNETS ARE SMALLER THAN ALL OTHERS
variable "networks" {
  type = object({
    cidr_block          = string
    public_subnets      = number
    private_subnets     = number
    db_subnets          = number
    public_cidr_bits    = number
    private_cidr_bits   = number
    db_cidr_bits        = number
    nat_gateways        = number
  })
  default = {
      cidr_block        = "10.0.0.0/16"
      public_subnets    = 3
      private_subnets   = 3
      db_subnets        = 3
      private_cidr_bits = 8
      public_cidr_bits  = 8
      db_cidr_bits      = 8
      nat_gateways      = 3   
    }
  description = "All information regarding network configuration is stored in this object. NOTE: THERE IS AN ASSUMPTION THAT PUBLIC SUBNETS ARE SMALLER THAN ALL OTHERS"
#  validation {
#    condition     = can(regex("((\\d\\d\\d)\\.){4}/\\d\\d", var.networks.cidr_block))
#    error_message = "The cidr block must be a valid cidr."
#  }
}


locals {
  total_subnets     = var.networks.public_subnets + var.networks.private_subnets + var.networks.db_subnets 
  name_tag_prefix   = "${var.project_name}-${var.environment}"
}

