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
