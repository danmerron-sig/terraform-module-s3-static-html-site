# terraform-module-s3-static-html-site
Creates a Static HTML S3 Bucket in AWS - Configures CloudFront attaches SSL and configures Route53. End to End Solution. 

Usage:

```module "<your module name>" {
  source = "<your module path>"
  name   = "<sub-domain>"
  ssl = "<ssl-arn>"
}```
