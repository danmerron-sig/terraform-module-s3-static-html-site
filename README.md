# terraform-module-s3-static-html-site
Creates a Static HTML S3 Bucket in AWS - Configures CloudFront attaches SSL and configures Route53. End to End Solution. 

module
` "s3-cdn-ssl" {
  source = "modules/s3-site"
  name   = "cleaner"
  ssl = "arn:aws:acm:us-east-1:628078894899:certificate/3f91cf23-71fb-4892-a693-8ada08e201c1"
}`
