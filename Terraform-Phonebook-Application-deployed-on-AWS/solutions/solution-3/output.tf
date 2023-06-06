# output "websiteurl" {
#     value = "http://${aws_alb.app-lb.dns_name}"
# }

output "site-name" {
  value = "http://${aws_route53_record.book-site.name}"
}