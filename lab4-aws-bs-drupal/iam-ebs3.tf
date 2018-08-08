# IAM user for S3 access in EB

# create user for S3 mount using fuse from eb EC2 nodes
resource "aws_iam_user" "eb-s3-user" {
  name = "${var.env}-${var.app}-ebs3"
}

# attach S3 on user
resource "aws_iam_user_policy_attachment" "eb-s3-user-attach" {
    user       = "${aws_iam_user.eb-s3-user.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# create keys
resource "aws_iam_access_key" "eb-s3-user-key" {
  user = "${aws_iam_user.eb-s3-user.name}"
}

# ---------------------------------------------------------------------------
#output "s3-user-key.id" {
#  value = "${aws_iam_access_key.eb-s3-user-key.id}"
#}

#output "s3-user-key.key" {
#  value = "${aws_iam_access_key.eb-s3-user-key.secret}"
#}
# ---------------------------------------------------------------------------