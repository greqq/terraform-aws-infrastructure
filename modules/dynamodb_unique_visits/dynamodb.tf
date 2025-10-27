# ============================================================================
# DYNAMODB UNIQUE VISITS MODULE - Unique Visitor Tracking
# ============================================================================
# This module creates a DynamoDB table to track unique visitors
#
# PURPOSE:
#   Prevent counting the same visitor multiple times
#   Implements "unique visits per day" logic

# TABLE STRUCTURE:
#   Primary Key: hashed_ip (String)
#   Example data:
#   {
#     "hashed_ip": "a3f2b8c9d1e4...",
#     "timestamp": 1729728000,
#     "ttl": 1729814400  (expires in 24 hours)
#   }
#
# PRIVACY:
#   - Stores hash, not actual IP address
#   - Hash changes daily (IP + date)
#   - TTL auto-deletes old entries
#   - Cannot reverse-engineer original IP
# ============================================================================

resource "aws_dynamodb_table" "unique_visitors_table" {
  name         = var.unique_visitor_table_name # "UniqueVisitors"
  billing_mode = var.billing_mode              # "PAY_PER_REQUEST"
  hash_key     = "hashed_ip"                   # Primary key: hashed IP+date

  # Attribute definitions
  attribute {
    name = "hashed_ip" # SHA256 hash of IP address + date
    type = "S"         # String type
  }

  # Optional: TTL (Time To Live) for automatic cleanup
  # Removes entries after they expire (reduces storage costs)
  # ttl {
  #   attribute_name = "ttl"
  #   enabled        = true
  # }

  tags = {
    Name        = "UniqueVisitors"
    Environment = "production"
  }
}
