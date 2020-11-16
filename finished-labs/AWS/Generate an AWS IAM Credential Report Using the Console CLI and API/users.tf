#####################
# USER VARIABLES
#####################

variable "user_count" {default = 5}
variable "default_user_prefix" { default = "user"}
variable "use_firstname_list" { default = "1"}



#####################
# CREATE SAMPLE USERS
#####################

# just simple user names user1,.. userX
resource "aws_iam_user" "simple_names" {
  count = var.user_count
  name = format("%s%s",var.default_user_prefix,count.index+1)
#  name = element(random_pet.random_names[*].id,count.index)
}

# output "names_out" {
#   value = simple_names.name[*].id
# }



# random user names - not using, commented out

# # Requires the `Random` Provider - it is installed by `terraform init`


# variable "firstname_list" { default = ["alex", "bob", "carol", "dinah","eduardo","franklin","georgia","henrietta"]}

# resource "random_string" "lastname" {
#   length  = 8
#   upper   = false
#   lower   = true
#   number  = false
#   special = false
# }

# resource "random_pet" "random_names" {
#   count  = var.user_count
#   separator = "."
#   length = 2
#   prefix = var.use_firstname_list == "0" ? var.default_prefix : element(var.firstname_list, count.index)
# }

# resource "aws_iam_user" "example" {
#   count = var.user_count
#   name = element(random_pet.random_names[*].id,count.index)
# }

