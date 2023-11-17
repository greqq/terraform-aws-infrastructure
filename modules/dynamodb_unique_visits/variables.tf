variable "aws_region" {
  description = "AWS Region for the resources"
  type     = string 
}

variable "unique_table_name" {
  description = "Table name"
  type        = string
}
variable "billing_mode" {
  description = "Billing mode for the table"
  type        = string
}