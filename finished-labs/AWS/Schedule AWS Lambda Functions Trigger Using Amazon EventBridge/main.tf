resource "aws_dynamodb_table" "event_details" {
  name           = "event_details"
  hash_key       = "event_id"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "event_id"
    type = "S"
  }
}