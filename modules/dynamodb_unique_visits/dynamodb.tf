resource "aws_dynamodb_table" "unique_visitors_table" {
  name         = var.unique_visitor_table_name
  billing_mode = var.billing_mode
  hash_key     = "hashed_ip"

  attribute {
    name = "hashed_ip"
    type = "S"
  }
}
