resource "aws_dynamodb_table" "orders_table" {
  name           = "globomantics_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "messageId"

  attribute {
    name = "messageId"
    type = "S"
  }
}
