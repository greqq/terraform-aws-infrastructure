resource "aws_dynamodb_table" "visitor_counter_table" {
  name         = var.visitor_counter_table_name
  billing_mode = var.billing_mode
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
