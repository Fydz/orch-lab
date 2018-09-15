resource "aws_s3_bucket" "s3" {
  bucket = "${var.env}-${var.app}-${random_id.r.dec}"
  acl    = "private"
  force_destroy = "true"
}

# ---------------------------------------------------------------------------
#output "s3-bucket" {
#  value = "${aws_s3_bucket.s3.id}"
#}
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "s3-drupal" {
  bucket = "${var.env}-${var.app}-${random_id.r.dec}-srcs"
  acl    = "private"
  force_destroy = "true"

  tags = {
    "environment" = "${var.env}"
    "application" = "${var.app}"
    "client" = "${var.customer}"
  }   
}

# ---------------------------------------------------------------------------
# output "s3-bucket" {
#  value = "${aws_s3_bucket.s3.id}"
# }
# ---------------------------------------------------------------------------

resource "aws_s3_bucket_object" "drupal" {
  bucket = "${aws_s3_bucket.s3-drupal.id}"
  key    = "drupal-v0.zip"
  source = "drupal-v0.zip"
}

# ---------------------------------------------------------------------------
output "s3-file-id" {
  value = "${aws_s3_bucket_object.drupal.id}"
}
# ---------------------------------------------------------------------------
