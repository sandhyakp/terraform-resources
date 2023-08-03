resource "aws_s3_bucket" "cfbucket" {
  bucket = "sandhya-webhost-12345"
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.cfbucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.cfbucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.cfbucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.cfbucket.id
  key    = "index.html"
  acl    = "public-read"
  source = "index.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.cfbucket.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_cloudfront_origin_access_control" "site_access" {
  name = "security_pillar100_cf_s3_oac"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource "aws_cloudfront_distribution" "site_access" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket.cfbucket.bucket_regional_domain_name
    origin_id    = "S3-${aws_s3_bucket.cfbucket.id}"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.cfbucket.id}"

    viewer_protocol_policy = "https-only"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [
    aws_s3_bucket_website_configuration.website,
    aws_s3_bucket_acl.example,
  ]
}
