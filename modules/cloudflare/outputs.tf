# resource "cloudflare_record" "records" {
#   for_each = { for record in var.dns_records : record.name => record }

#   zone_id = var.cloudflare_zone_id
#   name    = each.value.name
#   value   = each.value.value
#   type    = each.value.type
#   ttl     = 1 
# }
