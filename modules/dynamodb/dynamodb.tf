# ============================================================================
# DYNAMODB MODULE - Visitor Counter Table
# ============================================================================
# This module creates a DynamoDB table to store the total visitor count
##
# TABLE STRUCTURE:
#   Primary Key: id (String)
#   Example data:
#   {
#     "id": "visitors",
#     "count": 203
#   }
#
# ============================================================================

resource "aws_dynamodb_table" "visitor_counter_table" {
  name         = var.visitor_counter_table_name # "VisitorCounter"
  billing_mode = var.billing_mode               # "PAY_PER_REQUEST"
  hash_key     = "id"                           # Primary key (partition key)

  # Attribute definitions (only need to define keys)
  attribute {
    name = "id" # Primary key attribute
    type = "S"  # S = String, N = Number, B = Binary
  }

  # Optional: Enable point-in-time recovery for backups
  # point_in_time_recovery {
  #   enabled = true
  # }

  # Optional: Enable server-side encryption
  # server_side_encryption {
  #   enabled = true
  # }

  tags = {
    Name        = "VisitorCounter"
    Environment = "production"
  }
}
