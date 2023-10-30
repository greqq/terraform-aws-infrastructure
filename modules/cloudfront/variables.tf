variable "aliases" {
  description = "CloudFront Aliases"
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "ACM Certificate ARN"
  type        = string
}

variable "cloudfront_comment" {
  description = "Comment for the CloudFront distribution"
  type        = string
}

variable "price_class" {
  description = "Price class for the CloudFront distribution"
  type        = string
}

variable "origin_domain_name" {
  description = "Domain name for the origin"
  type        = string
}

variable "origin_id" {
  description = "ID for the origin"
  type        = string
}

variable "origin_access_control_id" {
  description = "Access control ID for the origin"
  type        = string
}

variable "target_origin_id" {
  description = "Target origin ID for the cache behavior"
  type        = string
}

variable "cache_policy_id" {
  description = "Cache policy ID for the cache behavior"
  type        = string
}

variable "minimum_protocol_version" {
  description = "Minimum protocol version for the viewer certificate"
  type        = string
}